import { Meilisearch } from "./meilisearch/meilisearch";
const indexId = process.argv[2];
const deleteOpt = process.argv[3];

// run with npm, add (-- -dd) options to delete existing indexed documents.
// npm run meilisearch:reindex:users -- -dd
// npm run meilisearch:reindex:posts -- -dd
// npm run meilisearch:reindex:comments -- -dd

// run with ts-node, add (-dd) options to delete existing indexed documents.
// ts-node meilisearch-reindex.ts users -dd
// ts-node meilisearch-reindex.ts posts -dd
// ts-node meilisearch-reindex.ts comments -dd

if (!indexId) {
  console.log("[NOTICE]: Please provide an index. It's either posts, comments, users.");
  process.exit(-1);
} else {
  Meilisearch.reIndex(indexId, Meilisearch.deleteOptions.includes(deleteOpt))
    .then((val) => process.exit(0))
    .catch((e) => console.error(e));
}
