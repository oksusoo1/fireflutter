import * as admin from "firebase-admin";
export class Storage {
  /**
   * Update post or comment id on the file meta.
   *
   * Note, for a test, id (post id or comment id) does not have to be exists.
   *    - But, the files(url) must exist in storage.
   *
   * @param id  post id or comment id.
   * @param data document data
   * @returns
   */
  static async updateFileParentId(id: string, data: any) {
    if (!data || !data.files || !data.files.length) {
      return;
    }
    const bucket = admin.storage().bucket();
    for (const url of data.files) {
      const f = bucket.file(this.getFilePathFromUrl(url));
      if (await f.exists()) {
        await f.setMetadata({
          metadata: {
            id: id,
          },
        });
      } else {
        console.log("ERROR -> file url not exists: ", url);
      }
    }
  }

  /**
   * Returns (first part) of metadata.
   *
   * The raw(whole) metadata looks a bit complicated and the first element of the metadata has important information.
   *
   * @param url url of an uploaded file(or image)
   * @returns first part of metadata. It has `metadata` property inside along with link, name, content type, etc.
   *
   * @example
   *  const metadata = await Storage.getMetadataFromUrl(
   *   "https://firebasestorage.googleapis.com/v0/b/withcenter-test-projec...25-deb.jpg?alt=media&token=e713c18e290"
   *  );
   *  console.log(metadata[0]);
   *  console.log(metadata[0].metadata);
   */
  static getMetadataFromUrl(url: string) {
    const file = admin.storage().bucket().file(this.getFilePathFromUrl(url));
    return file.getMetadata();
  }

  /**
   * Returns the storage path of the uploaded file.
   *
   * @param {*} url url of the uploaded file
   * @returns path of the uploaded file
   *
   * @usage Use this to get file from url.
   *
   * @example
   * admin.storage().bucket().file( getFilePathFromUrl('https://...'))
   */
  static getFilePathFromUrl(url: string) {
    const token = url.split("?");
    const parts = token[0].split("/");
    return parts[parts.length - 1].replaceAll("%2F", "/");
  }

  /**
   * Gets file reference from url.
   *
   * @param url
   * @returns
   */
  static getFileFromUrl(url: string) {
    if (url.startsWith("http")) {
      url = this.getFilePathFromUrl(url);
    }
    return admin.storage().bucket().file(url);
  }

  /**
   * Deletes a file from a url.
   *
   * @param url
   * @returns
   *
   * TODO: test
   */
  static async deleteFileFromUrl(url: string): Promise<void> {
    // If it's not a file from firebase storage, it does not do anything.
    if (url.includes("firebasestorage.googleapis.com") == false) {
      return;
    }

    if (url.startsWith("http")) {
      url = this.getFilePathFromUrl(url);
    }
    const file = admin.storage().bucket().file(url);
    const isExists = await file.exists();
    if (isExists[0]) await file.delete();
    else return;
  }
}

