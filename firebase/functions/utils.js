function removeHtmlTags(content) {
  return content.replace(/<[^>]+>/g, "");
}

exports.removeHtmlTags = removeHtmlTags;
