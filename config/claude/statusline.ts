const data = JSON.parse(await new Response(Deno.stdin.readable).text());

const BRAILLE = " ⣀⣄⣤⣦⣶⣷⣿";
const R = "\x1b[0m";
const DIM = "\x1b[2m";
const CYAN = "\x1b[38;2;86;182;194m";
const RED = "\x1b[38;2;255;85;85m";
const SEP = ` ${DIM}│${R} `;

function gradient(pct: number): string {
	if (pct < 50) {
		const r = Math.floor(pct * 5.1);
		return `\x1b[38;2;${r};200;80m`;
	}
	const g = Math.floor(200 - (pct - 50) * 4);
	return `\x1b[38;2;255;${Math.max(g, 0)};60m`;
}

function brailleBar(pct: number, width = 8): string {
	const _pct = Math.min(Math.max(pct, 0), 100);
	const level = _pct / 100;
	let bar = "";
	for (let i = 0; i < width; i++) {
		const segStart = i / width;
		const segEnd = (i + 1) / width;
		if (level >= segEnd) {
			bar += BRAILLE[7];
		} else if (level <= segStart) {
			bar += BRAILLE[0];
		} else {
			const frac = (level - segStart) / (segEnd - segStart);
			bar += BRAILLE[Math.min(Math.floor(frac * 7), 7)];
		}
	}
	return bar;
}

function fmt(label: string, pct: number): string {
	const p = Math.round(pct);
	return `${DIM}${label}${R} ${gradient(pct)}${brailleBar(pct)}${R} ${p}%`;
}

function formatTokens(n: number): string {
	if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}m`;
	if (n >= 1_000) return `${Math.floor(n / 1_000)}k`;
	return `${n}`;
}

// ── Line 1: model, context, rate limits ──
const model = data?.model?.display_name ?? "Claude";
const parts: string[] = [model];

const ctx = data?.context_window?.used_percentage ?? 0;
parts.push(fmt("ctx", ctx));

const five = data?.rate_limits?.five_hour?.used_percentage ?? 0;
parts.push(fmt("5h", five));

const week = data?.rate_limits?.seven_day?.used_percentage ?? 0;
parts.push(fmt("7d", week));

const line1 = parts.join(SEP);

// ── Line 2: tokens, latency ──
const inTokens = data?.context_window?.total_input_tokens ?? 0;
const outTokens = data?.context_window?.total_output_tokens ?? 0;
const durationMs = data?.cost?.total_api_duration_ms ?? 0;
const latency = (durationMs / 1000).toFixed(1);

const line2 = `${formatTokens(inTokens)}/${formatTokens(outTokens)} tokens${SEP}${latency}s`;

// ── Line 3: directory, git branch ──
const cwd: string = data?.cwd ?? "";
const home = cwd.match(/^(\/Users\/[^/]+)/)?.[1] ?? "";
const ghPrefix = home + "/workspaces/github.com/";
const dir = cwd.startsWith(ghPrefix)
	? cwd.slice(ghPrefix.length)
	: home && cwd.startsWith(home)
		? "~" + cwd.slice(home.length)
		: cwd;

const lastSlash = dir.lastIndexOf("/");
const dirDisplay = lastSlash >= 0
	? `${DIM}${dir.slice(0, lastSlash + 1)}${R}${dir.slice(lastSlash + 1)}`
	: dir;

let gitInfo = "";
if (cwd) {
	try {
		const p = new Deno.Command("git", {
			args: ["-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
			stdout: "piped",
			stderr: "null",
		});
		const out = await p.output();
		if (out.success) {
			const branch = new TextDecoder().decode(out.stdout).trim();
			let dirty = "";
			try {
				const s = new Deno.Command("git", {
					args: ["-C", cwd, "status", "--porcelain"],
					stdout: "piped",
					stderr: "null",
				});
				const sOut = await s.output();
				if (sOut.success && new TextDecoder().decode(sOut.stdout).trim()) {
					dirty = `${RED}*${R}`;
				}
			} catch { /* ignore */ }
			gitInfo = `${DIM} (${R}${CYAN}${branch}${dirty}${R}${DIM})${R}`;
		}
	} catch { /* git not available */ }
}

const line3 = `${dirDisplay}${gitInfo}`;

Deno.stdout.writeSync(new TextEncoder().encode(`${line1}\n${line2}\n${line3}`));
