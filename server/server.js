import { listenAndServe } from "https://deno.land/std/http/server.ts";
import { acceptWebSocket, acceptable } from "https://deno.land/std/ws/mod.ts";
import scrumpoker from "./scrumpoker.js";

const port = Deno.args[0] || 3000;
listenAndServe({ port: port }, async (req) => {
  if (req.method === "GET" && req.url === "/ws") {
    if (acceptable(req)) {
      acceptWebSocket({
        conn: req.conn,
        bufReader: req.r,
        bufWriter: req.w,
        headers: req.headers,
      }).then(scrumpoker);
    }
  }
});
console.log(`Scrum poker websocket server is running on :${port}`);

// Downgrade Deno in case the current Deno version fails
// $v="1.0.0"; iwr https://deno.land/x/install/install.ps1 -useb | iex
