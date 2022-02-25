function removeHtmlTags(content) {
  return content.replace(/<[^>]+>/g, "");
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

exports.removeHtmlTags = removeHtmlTags;
exports.getTimestamp = getTimestamp;
