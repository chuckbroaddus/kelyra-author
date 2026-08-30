let meta = #{
    name: "author-qa-loop",
    description: "Implement a Kelyra Author change, then loop author-implementer and read-only author-qa until P0/P1 are gone or three repair cycles elapse",
    when_to_use: "Use for any Author implementation that edits studio code, emitted packs, tests, or config. The parent session must launch this instead of writing code itself. Do not use for Q&A, planning, docs-only, git, or class-app work.",
    phases: [
        #{ title: "Implement", detail: "author-implementer writes the change in the current working tree" },
        #{ title: "QA", detail: "read-only author-qa inspects the working tree independently" },
        #{ title: "Repair", detail: "resume the original implementer for P0/P1 findings" },
        #{ title: "Verify", detail: "run typecheck and inexpensive tests when they exist" },
        #{ title: "Security", detail: "read-only security review only if sensitive boundaries changed" },
    ],
};

const MAX_QA_REPAIR = 3;
const MAX_VERIFY_REPAIR = 3;
const MAX_SECURITY_REPAIR = 3;

let blocking_item = #{
    "type": "object",
    "required": ["severity", "title", "failure_path", "evidence", "required_fix"],
    "properties": #{
        "severity": #{ "type": "string" },
        "title": #{ "type": "string" },
        "failure_path": #{ "type": "string" },
        "evidence": #{ "type": "string" },
        "required_fix": #{ "type": "string" },
    },
};
let nonblocking_item = #{
    "type": "object",
    "required": ["severity", "title", "evidence", "recommendation"],
    "properties": #{
        "severity": #{ "type": "string" },
        "title": #{ "type": "string" },
        "evidence": #{ "type": "string" },
        "recommendation": #{ "type": "string" },
    },
};
let impl_schema = #{
    "type": "object",
    "required": ["summary"],
    "properties": #{
        "summary": #{ "type": "string" },
        "changed_paths": #{
            "type": "array",
            "items": #{ "type": "string" },
            "maxItems": 80,
        },
        "notes": #{ "type": "string" },
    },
};
let qa_schema = #{
    "type": "object",
    "required": ["ok", "blocking", "nonblocking"],
    "properties": #{
        "ok": #{ "type": "boolean" },
        "blocking": #{ "type": "array", "maxItems": 20, "items": blocking_item },
        "nonblocking": #{ "type": "array", "maxItems": 20, "items": nonblocking_item },
        "touched_security_boundary": #{ "type": "boolean" },
        "changed_paths": #{
            "type": "array",
            "items": #{ "type": "string" },
            "maxItems": 80,
        },
    },
};
let verify_schema = #{
    "type": "object",
    "required": ["ok", "summary"],
    "properties": #{
        "ok": #{ "type": "boolean" },
        "summary": #{ "type": "string" },
        "skipped": #{ "type": "array", "items": #{ "type": "string" } },
        "ran": #{
            "type": "array",
            "maxItems": 12,
            "items": #{
                "type": "object",
                "required": ["command", "passed"],
                "properties": #{
                    "command": #{ "type": "string" },
                    "passed": #{ "type": "boolean" },
                    "output": #{ "type": "string" },
                },
            },
        },
        "blocking": #{ "type": "array", "maxItems": 12, "items": blocking_item },
    },
};

fn as_string(value) {
    if type_of(value) == "string" { value } else { "" }
}

fn as_lower(value) {
    if type_of(value) != "string" { return ""; }
    let copy = value;
    let lowered = copy.to_lower();
    if type_of(lowered) == "string" { return lowered; }
    copy.to_lower();
    copy
}

fn trimmed(value) {
    if type_of(value) != "string" { return ""; }
    let copy = value;
    copy.trim();
    copy
}

fn is_map(value) { type_of(value) == "map" }
fn is_array(value) { type_of(value) == "array" }

fn encode(value) {
    if value == () { "null" } else { json_encode(value) }
}

fn agent_ok(result) {
    result != () && result.success == true && result.cancelled != true
}

fn string_list(value) {
    let out = [];
    if !is_array(value) { return out; }
    for item in value {
        let s = trimmed(item);
        if s != "" { out.push(s); }
    }
    out
}

fn is_p0_or_p1(severity) {
    let s = as_lower(severity);
    s == "p0" || s == "p1"
}

fn push_p0_p1(into, items) {
    if !is_array(items) { return into; }
    for item in items {
        if is_map(item) && is_p0_or_p1(item.severity) {
            into.push(item);
        }
    }
    into
}

fn extract_blocking(output) {
    let found = [];
    if !is_map(output) { return found; }
    found = push_p0_p1(found, output.blocking);
    found = push_p0_p1(found, output.nonblocking);
    found
}

fn extract_nonblocking(output) {
    let found = [];
    if !is_map(output) { return found; }
    if is_array(output.nonblocking) {
        for item in output.nonblocking {
            if is_map(item) && !is_p0_or_p1(item.severity) {
                found.push(item);
            }
        }
    }
    if is_array(output.blocking) {
        for item in output.blocking {
            if is_map(item) && !is_p0_or_p1(item.severity) {
                found.push(item);
            }
        }
    }
    found
}

fn hay_has_any(hay, needles) {
    let h = as_lower(hay);
    if h == "" { return false; }
    for needle in needles {
        if h.contains(needle) { return true; }
    }
    false
}

fn request_looks_sensitive(request) {
    let needles = [
        "student pii",
        "pii",
        "kelyra.identity",
        "postmessage",
        "api key",
        "api_key",
        "secret",
        "package zip",
        ".zip",
        "index.html",
        "manifest.json",
        "path traversal",
        "projects/kelyra",
        "class app",
        "public bucket",
        "public url",
        "hosted url",
        "identity",
    ];
    hay_has_any(request, needles)
}

fn path_looks_sensitive(path) {
    let needles = [
        "index.html",
        "manifest.json",
        ".zip",
        "pack",
        "emit",
        "output",
        "docs/package-spec",
        "projects/kelyra",
        ".env",
        "secret",
        "identity",
        "kelyra.identity",
    ];
    hay_has_any(path, needles)
}

fn collect_paths(impl_out, qa_out) {
    let paths = [];
    if is_map(impl_out) {
        for p in string_list(impl_out.changed_paths) { paths.push(p); }
    }
    if is_map(qa_out) {
        for p in string_list(qa_out.changed_paths) { paths.push(p); }
    }
    paths
}

fn needs_security_review(request, impl_out, qa_out) {
    if is_map(qa_out) && qa_out.touched_security_boundary == true { return true; }
    if request_looks_sensitive(request) { return true; }
    let paths = collect_paths(impl_out, qa_out);
    for p in paths {
        if path_looks_sensitive(p) { return true; }
    }
    false
}

fn read_request(raw) {
    if raw == () { return (); }
    let kind = type_of(raw);
    if kind == "string" {
        let s = trimmed(raw);
        if s == "" { return (); }
        return s;
    }
    if kind != "map" { return (); }
    let cand = ();
    if raw.request != () {
        cand = raw.request;
    } else if raw.task != () {
        cand = raw.task;
    } else if raw.prompt != () {
        cand = raw.prompt;
    } else if raw.objective != () {
        cand = raw.objective;
    }
    let s = trimmed(cand);
    if s == "" { return (); }
    s
}

fn author_invariants_text() {
    let t = "";
    t += "Author invariants: do not edit ~/projects/kelyra (class app); ";
    t += "no student PII in package files; identity arrives via postMessage kelyra.identity, never in the URL; ";
    t += "emit the live player contract: index.html + optional manifest.json, kelyra.lesson complete this_visit, ";
    t += "marks/hints/audio_used/kinetic_used/item_ids/item_stems/skipped/wrong/later_corrected/hinted; ";
    t += "STYLE-BRIEF is the quality bar — generic AI-looking output is a P1 for pack emit; ";
    t += "paper math on stage, ASCII aliases on input (2^3, 2*2*2); ";
    t += "no public bucket, no URL on catalog rows; do not generate a second player or a hosted public URL; ";
    t += "secrets never in client packs; smallest change; do not invent marketplace, quiz kinds, or a second runtime; ";
    t += "do not git reset/checkout/restore/clean/stash/commit/push; follow AGENTS.md and docs/package-spec.md.\n";
    t
}

fn impl_initial_prompt(request_json) {
    let p = "";
    p += "You are the Kelyra Author implementation agent (persona author-implementer).\n";
    p += "Do not spawn subagents. Do not call spawn_subagent. Implement this request yourself.\n";
    p += "Never call ask_user_question. Never probe whether a tool exists. Do not send dummy Continue / placeholder questions. If you cannot inspect something, record that as evidence and still return the JSON report. Do not wait for a human.\n";
    p += "You have write access to the CURRENT working tree. isolation is off.\n";
    p += "This repo is ~/projects/kelyra-author. NEVER edit ~/projects/kelyra (class app).\n";
    p += "Preserve existing uncommitted work. Do not git reset, git checkout, git restore, ";
    p += "git clean, git stash, commit, or push, or otherwise discard unrelated changes.\n";
    p += "Edit only files required for THIS request. Smallest correct change. No extra features.\n";
    p += "Do not invent marketplace, quiz kinds, or a second runtime.\n";
    p += "Before editing: read AGENTS.md, inspect surrounding code and tests, ";
    p += "and read docs/package-spec.md and docs/STYLE-BRIEF.md when emitting packs.\n";
    p += author_invariants_text();
    p += "Use read_file, grep, and search_replace/write on the actual tree. Do not answer from memory.\n";
    p += "Add or update tests when appropriate. Never weaken or delete a test to make it pass.\n";
    p += "When done, set summary to what you changed and changed_paths to repo-relative paths you edited.\n";
    p += "REQUEST (JSON):\n";
    p += request_json;
    p += "\n";
    p
}

fn impl_fix_prompt(kind, request_json, findings_json) {
    let p = "";
    p += "Resume Kelyra Author implementation. Do not spawn subagents.\n";
    p += "Never call ask_user_question. Never probe whether a tool exists. Do not send dummy Continue / placeholder questions. If you cannot inspect something, record that as evidence and still return the JSON report. Do not wait for a human.\n";
    p += "NEVER edit ~/projects/kelyra. Preserve unrelated working-tree changes. No git reset/checkout/restore/clean/stash/commit/push.\n";
    p += "Fix only the blocking P0/P1 findings below. Smallest correct fix. Add a regression test when appropriate.\n";
    p += "Inspect the actual code for each finding. Do not patch a symptom if the root cause is nearby.\n";
    p += author_invariants_text();
    p += "KIND: ";
    p += kind;
    p += "\nORIGINAL REQUEST (JSON):\n";
    p += request_json;
    p += "\nBLOCKING FINDINGS (JSON):\n";
    p += findings_json;
    p += "\nUpdate summary and changed_paths for files you edited in this repair.\n";
    p
}

fn qa_prompt(request_json, impl_json) {
    let p = "";
    p += "You are the Kelyra Author QA reviewer (persona author-qa). You are READ-ONLY.\n";
    p += "Do not modify files. Do not spawn subagents. Do not call spawn_subagent.\n";
    p += "Never call ask_user_question. Never probe whether a tool exists. Do not send dummy Continue / placeholder questions. If you cannot inspect something, record that as evidence and still return the JSON report. Do not wait for a human.\n";
    p += "Independently inspect the actual working tree. Do not trust the implementer summary as evidence.\n";
    p += "You have no shell. Reconstruct the change by reading files with read_file and grep.\n";
    p += "Read AGENTS.md and docs/package-spec.md. STYLE-BRIEF is the quality bar for pack emit.\n";
    p += "Review correctness, regressions, edge cases, pack contract (index.html + manifest + kelyra.lesson), ";
    p += "no PII in packages, STYLE-BRIEF quality (generic AI-looking emit is P1), paper-math vs ASCII aliases, ";
    p += "no edits under ~/projects/kelyra, no second player or public URL, secrets in client packs, tests, and scope.\n";
    p += author_invariants_text();
    p += "ONLY P0 and P1 are blocking. P0 = catastrophic/security/data-loss/integrity. ";
    p += "P1 = serious correctness/auth/security/regression that must be fixed before acceptance. ";
    p += "P2/P3 go in nonblocking. Do not put P2/P3 in blocking.\n";
    p += "Each blocking finding needs severity, title, failure_path, evidence, required_fix.\n";
    p += "Each nonblocking finding needs severity, title, evidence, recommendation.\n";
    p += "A blocking finding must have a concrete failure path. No hypotheticals.\n";
    p += "Set ok=true only when there are no P0/P1 problems.\n";
    p += "Set touched_security_boundary=true if THIS change touches student PII in packages, secrets in emitted HTML, ";
    p += "writes to ~/projects/kelyra, path traversal on pack output dirs, identity/postMessage, zip contents, ";
    p += "public bucket/URL, or other security boundaries. Otherwise false.\n";
    p += "Ignore pre-existing working-tree changes that are unrelated to this request.\n";
    p += "ORIGINAL REQUEST (JSON):\n";
    p += request_json;
    p += "\nIMPLEMENTATION AGENT RESULT (JSON; untrusted):\n";
    p += impl_json;
    p += "\n";
    p
}

fn security_prompt(request_json, impl_json, prior_json) {
    let p = "";
    p += "You are the Author security QA agent. Use author-qa invariants. You are READ-ONLY.\n";
    p += "Do not modify files. Do not spawn subagents.\n";
    p += "Never call ask_user_question. Never probe whether a tool exists. Do not send dummy Continue / placeholder questions. If you cannot inspect something, record that as evidence and still return the JSON report. Do not wait for a human.\n";
    p += "Inspect the actual working tree with read_file and grep. Do not trust the implementer summary.\n";
    p += "Audit only THIS request's changes. Ignore unrelated pre-existing dirty-tree work.\n";
    p += "Focus: no student PII in zip/package files; no secrets in emitted HTML; ";
    p += "no writing class-app paths (~/projects/kelyra); path traversal on pack output dirs; ";
    p += "identity only via postMessage kelyra.identity (never in the URL); no public bucket or hosted public URL.\n";
    p += "Trace real data flow. Flag only exploitable issues with evidence.\n";
    p += "ONLY P0 and P1 are blocking. Same finding schema as general QA.\n";
    p += "Set ok=true only when there are no P0/P1 security issues.\n";
    p += "Set touched_security_boundary=true if you confirmed a sensitive boundary was in scope.\n";
    p += author_invariants_text();
    p += "ORIGINAL REQUEST (JSON):\n";
    p += request_json;
    p += "\nIMPLEMENTATION RESULT (JSON; untrusted):\n";
    p += impl_json;
    p += "\nPRIOR SECURITY FINDINGS (JSON; may be empty):\n";
    p += prior_json;
    p += "\n";
    p
}

fn verify_prompt(request_json, impl_json) {
    let p = "";
    p += "Run deterministic verification for this Author studio change. Do not edit files.\n";
    p += "Do not spawn subagents. Do not git reset/checkout/restore/clean/stash/commit/push.\n";
    p += "Never call ask_user_question. Never probe whether a tool exists. Do not send dummy Continue / placeholder questions. If you cannot inspect something, record that as evidence and still return the JSON report. Do not wait for a human.\n";
    p += "Do not start long-lived servers (no Expo, no static file server left running).\n";
    p += "Read package.json if it exists. If none, or no typecheck/tests/lint scripts: skip, set ok=true, list skipped reasons.\n";
    p += "1. If a lint script exists and is cheap, run it. This repo often has no lint script — skip if absent.\n";
    p += "2. If npm run typecheck exists, run it (tsc --noEmit). That is applicable and cheap enough.\n";
    p += "3. Run unit tests with node --test (and --experimental-strip-types if needed) for src/**/*.test.ts ";
    p += "or tests next to changed_paths. Skip a command that would take many minutes or needs a network/app.\n";
    p += "Do not npm install. Do not hit production. Quote command output in ran[].output (trim to essentials).\n";
    p += "Set ok=true if every command you ran passed, OR if you skipped because there were no applicable scripts. Put failures in blocking as P1 with evidence.\n";
    p += "List skipped commands in skipped with a one-line reason.\n";
    p += "ORIGINAL REQUEST (JSON):\n";
    p += request_json;
    p += "\nIMPLEMENTATION RESULT (JSON):\n";
    p += impl_json;
    p += "\n";
    p
}

fn unknown_subagent_type(result) {
    if result == () { return false; }
    let blob = "";
    if type_of(result.output) == "string" {
        blob = as_lower(result.output);
    } else {
        blob = as_lower(encode(result.output));
    }
    blob.contains("unknown subagent type")
}

fn impl_opts(label, resume_id, schema, type_name) {
    let opts = #{
        label: label,
        agent_type: type_name,
        model: "grok-4.5",
        capability_mode: "all",
        isolation_worktree: false,
        output_schema: schema,
    };
    if resume_id != () {
        opts.resume_from = resume_id;
    }
    opts
}

fn qa_opts(label, schema, type_name) {
    #{
        label: label,
        agent_type: type_name,
        model: "grok-4.5",
        capability_mode: "read-only",
        output_schema: schema,
    }
}

fn verify_opts(schema) {
    #{
        label: "[verify] typecheck and tests",
        agent_type: "general-purpose",
        model: "grok-4.5",
        capability_mode: "execute",
        output_schema: schema,
    }
}

fn latest_impl_id(result, previous) {
    if agent_ok(result) && result.agent_id != () { result.agent_id } else { previous }
}

fn impl_output_of(result) {
    if result != () { result.output } else { () }
}

fn findings_as_blocking(command_output) {
    let found = extract_blocking(command_output);
    if found.len() > 0 { return found; }
    if is_map(command_output) && command_output.ok == false {
        let item = #{
            severity: "P1",
            title: "Deterministic verification failed",
            failure_path: as_string(command_output.summary),
            evidence: encode(command_output),
            required_fix: "Make applicable typecheck/tests pass, or skip with reasons if no package.json scripts exist. Do not discard unrelated work.",
        };
        found.push(item);
    }
    found
}

fn render_findings(title, items) {
    let t = "## ";
    t += title;
    t += "\n\n";
    if !is_array(items) || items.len() == 0 {
        t += "_None._\n\n";
        return t;
    }
    let i = 1;
    for item in items {
        t += i.to_string();
        t += ". ";
        if is_map(item) {
            t += as_string(item.severity);
            t += " — ";
            t += as_string(item.title);
            t += "\n";
            if item.failure_path != () {
                t += "   - failure_path: ";
                t += as_string(item.failure_path);
                t += "\n";
            }
            if item.evidence != () {
                t += "   - evidence: ";
                t += as_string(item.evidence);
                t += "\n";
            }
            if item.required_fix != () {
                t += "   - required_fix: ";
                t += as_string(item.required_fix);
                t += "\n";
            }
            if item.recommendation != () {
                t += "   - recommendation: ";
                t += as_string(item.recommendation);
                t += "\n";
            }
        }
        t += "\n";
        i += 1;
    }
    t
}

fn finish(outcome, summary, request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out) {
    let report = "";
    report += "# author-qa-loop\n\n";
    report += "- outcome: ";
    report += outcome;
    report += "\n- summary: ";
    report += summary;
    report += "\n- qa_repair_cycles: ";
    report += qa_repairs.to_string();
    report += " / 3\n- verify_repair_cycles: ";
    report += verify_repairs.to_string();
    report += " / 3\n- security_repair_cycles: ";
    report += security_repairs.to_string();
    report += " / 3\n- security_ran: ";
    if security_ran { report += "true"; } else { report += "false"; }
    report += "\n- security_ok: ";
    if security_ok { report += "true"; } else { report += "false"; }
    report += "\n\n## Request\n\n";
    report += request;
    report += "\n\n## Implementation summary\n\n";
    if is_map(impl_out) {
        report += as_string(impl_out.summary);
        report += "\n";
    } else {
        report += encode(impl_out);
        report += "\n";
    }
    report += "\n";
    report += render_findings("Blocking (P0/P1)", blocking);
    report += render_findings("Nonblocking (P2/P3)", nonblocking);
    if outcome == "escalated" {
        report += "Remaining P0/P1 findings are escalated to the parent session. This workflow will not start another repair cycle.\n";
    }
    let path = write_scratch_file("report.md", report);
    log(summary);
    complete(#{
        path: path,
        report: report,
        outcome: outcome,
        summary: summary,
        qa_repair_cycles: qa_repairs,
        verify_repair_cycles: verify_repairs,
        security_repair_cycles: security_repairs,
        security_ran: security_ran,
        security_ok: security_ok,
        blocking: blocking,
        nonblocking: nonblocking,
        implementation: impl_out,
    });
}

let request = read_request(args);
if request == () {
    pause("verification", "Pass args.request (or args.task / a string arg) with the implementation request.");
}

let request_json = encode(request);
let impl_id = ();
let impl_out = ();
let qa_out = ();
let blocking = [];
let nonblocking = [];
let qa_repairs = 0;
let verify_repairs = 0;
let security_repairs = 0;
let security_ran = false;
let security_ok = true;
let last_security_blocking = [];
let impl_type = "author-implementer";
let qa_type = "author-qa";

phase("Implement");
log("Implementing in the current working tree (author-implementer, grok-4.5)");
let impl_res = agent(impl_initial_prompt(request_json), impl_opts("[author-implementer] implement", (), impl_schema, impl_type));
if !agent_ok(impl_res) && unknown_subagent_type(impl_res) {
    log("author-implementer is not a registered agent type; falling back to general-purpose with the same persona prompt");
    impl_type = "general-purpose";
    impl_res = agent(impl_initial_prompt(request_json), impl_opts("[author-implementer] implement", (), impl_schema, impl_type));
}
impl_id = latest_impl_id(impl_res, impl_id);
impl_out = impl_output_of(impl_res);
if !agent_ok(impl_res) {
    finish("escalated", "Implementation agent failed.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
}

let step = "qa";
let looping = true;
while looping {
    if step == "qa" {
        phase("QA");
        log("Read-only QA (author-qa, grok-4.5)");
        let qa_res = agent(qa_prompt(request_json, encode(impl_out)), qa_opts("[author-qa] review", qa_schema, qa_type));
        if !agent_ok(qa_res) && unknown_subagent_type(qa_res) {
            log("author-qa is not a registered agent type; falling back to general-purpose with the same persona prompt");
            qa_type = "general-purpose";
            qa_res = agent(qa_prompt(request_json, encode(impl_out)), qa_opts("[author-qa] review", qa_schema, qa_type));
        } else if !agent_ok(qa_res) {
            log("QA agent failed; retrying once");
            qa_res = agent(qa_prompt(request_json, encode(impl_out)), qa_opts("[author-qa] review retry", qa_schema, qa_type));
        }
        if !agent_ok(qa_res) {
            finish("escalated", "QA agent failed twice; escalating to the parent session.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
        }
        qa_out = qa_res.output;
        blocking = extract_blocking(qa_out);
        nonblocking = extract_nonblocking(qa_out);
        let nblock = blocking.len();
        log(nblock.to_string() + " blocking P0/P1 finding(s); ok=" + encode(is_map(qa_out) && qa_out.ok == true));
        if nblock == 0 {
            step = "verify";
        } else if qa_repairs >= MAX_QA_REPAIR {
            finish("escalated", "QA still reports P0/P1 after three repair cycles.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
        } else if impl_id == () {
            finish("escalated", "Cannot resume implementer: missing agent_id.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
        } else {
            qa_repairs += 1;
            phase("Repair");
            log("Resuming original implementer for QA findings (repair " + qa_repairs.to_string() + "/3)");
            impl_res = agent(impl_fix_prompt("qa", request_json, encode(blocking)), impl_opts("[author-implementer] fix QA findings", impl_id, impl_schema, impl_type));
            impl_id = latest_impl_id(impl_res, impl_id);
            impl_out = impl_output_of(impl_res);
            if !agent_ok(impl_res) {
                finish("escalated", "Resumed implementer failed while fixing QA findings.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
            }
        }
    } else if step == "verify" {
        phase("Verify");
        log("Deterministic typecheck/tests when inexpensive and applicable");
        let ver_res = agent(verify_prompt(request_json, encode(impl_out)), verify_opts(verify_schema));
        if !agent_ok(ver_res) {
            log("Verify agent failed; retrying once");
            ver_res = agent(verify_prompt(request_json, encode(impl_out)), verify_opts(verify_schema));
        }
        if !agent_ok(ver_res) {
            finish("escalated", "Verify agent failed twice; escalating to the parent session.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
        }
        let verify_out = ver_res.output;
        let verify_blocking = findings_as_blocking(verify_out);
        if verify_blocking.len() == 0 && !(is_map(verify_out) && verify_out.ok == false) {
            step = "security";
        } else if verify_repairs >= MAX_VERIFY_REPAIR {
            blocking = verify_blocking;
            finish("escalated", "Typecheck/tests still failing after three repair cycles.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
        } else if impl_id == () {
            finish("escalated", "Cannot resume implementer: missing agent_id.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
        } else {
            verify_repairs += 1;
            phase("Repair");
            log("Resuming original implementer for verify failures (repair " + verify_repairs.to_string() + "/3)");
            impl_res = agent(impl_fix_prompt("verify", request_json, encode(verify_blocking)), impl_opts("[author-implementer] fix verify failures", impl_id, impl_schema, impl_type));
            impl_id = latest_impl_id(impl_res, impl_id);
            impl_out = impl_output_of(impl_res);
            if !agent_ok(impl_res) {
                finish("escalated", "Resumed implementer failed while fixing verify failures.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
            }
            step = "qa";
        }
    } else if step == "security" {
        let sensitive = needs_security_review(request, impl_out, qa_out);
        if !sensitive {
            log("Skipping security review; this change did not touch a listed security boundary");
            looping = false;
        } else {
            security_ran = true;
            phase("Security");
            log("Read-only security QA (author-qa, grok-4.5)");
            let sec_res = agent(security_prompt(request_json, encode(impl_out), encode(last_security_blocking)), qa_opts("[author-qa] security review", qa_schema, qa_type));
            if !agent_ok(sec_res) {
                log("Security QA failed; retrying once");
                sec_res = agent(security_prompt(request_json, encode(impl_out), encode(last_security_blocking)), qa_opts("[author-qa] security review retry", qa_schema, qa_type));
            }
            if !agent_ok(sec_res) {
                finish("escalated", "Security QA agent failed twice; escalating to the parent session.", request, qa_repairs, verify_repairs, security_repairs, security_ran, false, blocking, nonblocking, impl_out);
            }
            let sec_out = sec_res.output;
            last_security_blocking = extract_blocking(sec_out);
            if is_map(sec_out) {
                let extra = extract_nonblocking(sec_out);
                for item in extra { nonblocking.push(item); }
            }
            if last_security_blocking.len() == 0 {
                security_ok = true;
                looping = false;
            } else if security_repairs >= MAX_SECURITY_REPAIR {
                security_ok = false;
                blocking = last_security_blocking;
                finish("escalated", "Security QA still reports P0/P1 after three repair cycles.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
            } else if impl_id == () {
                finish("escalated", "Cannot resume implementer: missing agent_id.", request, qa_repairs, verify_repairs, security_repairs, security_ran, false, last_security_blocking, nonblocking, impl_out);
            } else {
                security_ok = false;
                security_repairs += 1;
                phase("Repair");
                log("Resuming original implementer for security findings (repair " + security_repairs.to_string() + "/3)");
                impl_res = agent(impl_fix_prompt("security", request_json, encode(last_security_blocking)), impl_opts("[author-implementer] fix security findings", impl_id, impl_schema, impl_type));
                impl_id = latest_impl_id(impl_res, impl_id);
                impl_out = impl_output_of(impl_res);
                if !agent_ok(impl_res) {
                    finish("escalated", "Resumed implementer failed while fixing security findings.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, last_security_blocking, nonblocking, impl_out);
                }
                step = "qa";
            }
        }
    } else {
        looping = false;
    }
}

finish("passed", "QA passed with no P0/P1 findings.", request, qa_repairs, verify_repairs, security_repairs, security_ran, security_ok, blocking, nonblocking, impl_out);
