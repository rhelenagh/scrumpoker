import { isWebSocketCloseEvent } from "https://deno.land/std/ws/mod.ts";
import { v4 } from "https://deno.land/std/uuid/mod.ts";

/**
     * session: {
     *   sessionId : String,
     *   sessionName : String,    
     *   status : String,    
     *   members : [String],    
     *   ws: WebSocket
     * }
    */
const sessionMap = new Map();

export default async function scrumpoker(ws) {
  const pre_sessionId = v4.generate();
  const sessionId = pre_sessionId.substr(0, 4);

  /**
     * member: {
     *   id: String,
     *   sessionId : String,
     *   members: [],     
     *   ws: WebSocket
     * }
    */
  const membersMap = new Map();

  // Sync loop for wait for data
  for await (let data of ws) {
    const event = typeof data === "string" ? JSON.parse(data) : data;
    if (isWebSocketCloseEvent(data)) {
      // TODO implement
      break;
    }

    const eventData = event.data ? JSON.parse(event.data) || {} : {};

    console.log(eventData);

    switch (event.type) {
      case "create":
        createSession(sessionId, eventData, ws);
        break;

      case "joined":
        joinedToSession(eventData, ws);
        break;

      case "update_session":
        updateSession(eventData);
        break;

      case "vote":
        voteFromMembers(eventData);
        break;

      default:
        break;
    }
  }

  function createSession(sessionId, eventData, ws) {
    // Create session obj
    let sessionObj;
    sessionObj = {
      sessionId: sessionId,
      sessionName: eventData.sessionName,
      status: "Open",
      members: [],
      ws,
    };

    // Save session Obj in the sessionMap
    sessionMap.clear();
    sessionMap.set(sessionId, sessionObj);

    const msg = {
      type: "session",
      id: sessionId,
      sessionName: eventData.sessionName,
      status: "Open",
    };
    ws.send(JSON.stringify(msg));
  }

  function joinedToSession(eventData, ws) {
    // check if sessionid is valid or exist
    if (sessionMap.has(eventData.sessionId)) {
      let memberObj;

      // get the session to join
      const session = sessionMap.get(eventData.sessionId);

      /*
      const _addedMember = [...session.members].concat(
        [{ memberName: eventData.memberName, vote: 0 }],
      );
      */

      if (session.status !== "Closed") {
        const member_Id = v4.generate();

        // Create member object
        memberObj = {
          id: member_Id,
          sessionId: eventData.sessionId,
          members: eventData.memberName, //_addedMember,
          ws,
        };

        membersMap.set(member_Id, memberObj);

        const msg = {
          type: "newMember",
          id: memberObj.id,
          sessionId: memberObj.sessionId,
          memberName: eventData.memberName,
          vote: 0,
        };
        ws.send(JSON.stringify(msg));

        // Send to original Session -Test this one
        session.ws.send(JSON.stringify(msg));
      } else {
        const msg = {
          type: "sessionClosed",
        };
        ws.send(JSON.stringify(msg));
      }
    } // session not found
    else {
      const msg = {
        type: "sessionNotFound",
      };
      ws.send(JSON.stringify(msg));
    }
  }

  function updateSession(eventData) {
    // check if sessionid is valid or exist
    if (sessionMap.has(eventData.id)) {
      // get the session to update
      const session = sessionMap.get(eventData.id);

      session.status = eventData.status;

      // update Map
      sessionMap.set(eventData.id, session);

      const msg = {
        type: "updateSessionOk",
      };

      // Send to original Session
      session.ws.send(JSON.stringify(msg));
    }
  }

  function voteFromMembers(eventData) {
    // check if sessionid is valid or exist
    if (sessionMap.has(eventData.sessionId)) {
      // get the master session
      const session = sessionMap.get(eventData.sessionId);

      // Response to the original session
      const msg = {
        type: "memberVote",
        memberName: eventData.memberName,
        vote: eventData.vote,
      };

      session.ws.send(JSON.stringify(msg));
    }
  }
}
