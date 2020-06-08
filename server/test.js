const sessionMap = new Map();
let memberObj;

const id = 1;

let internalid = id + 1;

// add some data
console.log("Add data");

let memebername = "El Cuco";
_addMemeber(memebername, 5);

memebername = "Sting";
_addMemeber(memebername), 4;

memebername = "Leo";
_addMemeber(memebername, 8);

memebername = "Remo";
_addMemeber(memebername, 7);

memebername = "Moritz";
_addMemeber(memebername, 9);

memebername = "Ingo";
_addMemeber(memebername, 32);

memebername = "Björn";
_addMemeber(memebername, 40);

memebername = "Ingo";
_addMemeber(memebername, 72);

_retrieveValues();

_updateIngoVote("Ingo", 66);

_retrieveValues();

function _addMemeber(member, vote) {
  if (sessionMap.has(id)) {
    let res = sessionMap.get(id);

    const _addedMember = [...res.members].concat(
      [{ memberName: member, vote: vote }],
    );
    memberObj = {
      id: internalid,
      members: _addedMember,
      sessionId: res.sessionId,
    };
    sessionMap.set(id, memberObj);
  } else {
    memberObj = {
      id: internalid,
      members: [{ memberName: member, vote: vote }],
      sessionId: id,
    };

    sessionMap.set(id, memberObj);
  }
}

function _updateIngoVote(_membername, _newVote) {
  if (sessionMap.has(id)) {
    let res = sessionMap.get(id);

    // First alternative to update
    //let foundMember = res.members.findIndex(m => m.memberName == _membername);
    //res.members[foundMember] = {memberName: _membername, vote: _newVote };

    // Second one
    Object.assign(
      res.members,
      res.members.map((el) =>
        el.memberName === _membername
          ? { memberName: _membername, vote: _newVote }
          : el
      ),
    );

    // the third option Modify object property
    //let updateMember = res.members.find((m) => { return m.memberName == _membername });
    //updateMember.vote = _newVote;

    sessionMap.set(id, res);
  }
}

function _retrieveValues() {
  const res = sessionMap.get(id);
  console.log(`sessionMap values ${JSON.stringify(res)}`);
}
