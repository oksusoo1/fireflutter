import { Meilisearch } from "./meilisearch/meilisearch";
const scope = process.argv[2];
const deleteOpt = process.argv[3];

// run with npm, add (-- -dd) options to delete existing indexed documents.
// npm run meilisearch:reindex:users -- -dd
// npm run meilisearch:reindex:forum -- -dd

// run with ts-node, add (-dd) options to delete existing indexed documents.
// ts-node meilisearch-reindex.ts users -dd
// ts-node meilisearch-reindex.ts forum -dd

if (!scope) {
  console.log("[NOTICE]: Please provide a scope for indexing. It's either `forum` or `users`.");
  process.exit(-1);
} else {
  Meilisearch.reIndexDocuments(scope, Meilisearch.deleteOptions.includes(deleteOpt))
    .then((val) => process.exit(0))
    .catch((e) => console.error(e));
}
