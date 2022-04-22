import { Meilisearch } from "./meilisearch/meilisearch";


  Meilisearch.resetSearchSettings()
    .then((val) => {
      console.log('Search settings updated!');
      process.exit(0);
    })
    .catch((e) => console.error(e));