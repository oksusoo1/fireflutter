/**
 * It returns string after removing html tags.
 *
 * @param {*} content string
 */
function removeHtmlTags(content) {
  if (content) {
    return content.replace(/<[^>]+>/g, "");
  } else {
    return content;
  }
}

/**
 * Convert html entities into code.
 *
 * @param {*} text HTML string
 */
function decodeHTMLEntities(text) {
  const entities = {
    "amp": "&",
    "apos": "'",
    "#x27": "'",
    "#x2F": "/",
    "#39": "'",
    "#47": "/",
    "lt": "<",
    "gt": ">",
    "nbsp": " ",
    "quot": "\"",
    "bull": "•",
  };
  return text.replace(/&([^;]+);/gm, function(match, entity) {
    return entities[entity] || match;
  });
}

/**
 * Returns unix timestamp
 *
 * @return int unix timestamp
 */
function getTimestamp(servertime) {
  if (servertime) {
    const d = servertime.toDate();
    return Math.round(d.getTime() / 1000);
  } else {
    return Math.round(new Date().getTime() / 1000);
  }
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

exports.removeHtmlTags = removeHtmlTags;
exports.getTimestamp = getTimestamp;
exports.decodeHTMLEntities = decodeHTMLEntities;
exports.getRandomInt = getRandomInt;
