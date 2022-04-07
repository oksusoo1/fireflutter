import * as admin from "firebase-admin";

/**
 *
 * @reference
 * - File object at https://googleapis.dev/nodejs/storage/latest/File.html
 * - UploadResponse at https://googleapis.dev/nodejs/storage/latest/global.html#UploadResponse
 * - How to upload with node.js at https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-code-sample
 */
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
      const f = bucket.file(this.getPathFromUrl(url));
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
    const file = admin.storage().bucket().file(this.getPathFromUrl(url));
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
   * admin.storage().bucket().file( getPathFromUrl('https://...'))
   */
  static getPathFromUrl(url: string) {
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
  static getRefFromUrl(url: string) {
    const path = this.getPathFromUrl(url);
    return admin.storage().bucket().file(path);
  }

  /**
   * Returns a file reference
   * @param path path like '/uploads/abc.jpg'
   */
  static getRefFromPath(path: string) {
    return admin.storage().bucket().file(path);
  }

  /**
   * Gets the thumbnail URL of a file.
   *
   * @param url is the original url.
   * @returns thumbnail url.
   *
   */
  static getThumbnailUrl(url: string) {
    let _tempUrl = url;
    if (_tempUrl.indexOf("?") > 0) {
      _tempUrl = _tempUrl.split("?")[0];
    }
    const basename = _tempUrl.split("/").pop();
    const filename = basename!.split(".")[0];
    return _tempUrl.replace(basename!, `${filename}_200x200.webp`) + "?alt=media";
  }

  /**
   * Check where or not a file url is an image url (not thumbnail url).
   *
   * @param url
   * @returns
   */
  static isImageUrl(url: string): boolean {
    const t = url.toLowerCase();
    if (t.endsWith(".jpg")) return true;
    if (t.endsWith(".jpeg")) return true;
    if (t.endsWith(".png")) return true;
    if (t.endsWith(".gif")) return true;

    if (
      t.startsWith("http") &&
      (t.includes(".jpg") || t.includes(".jpeg") || t.includes(".png") || t.includes(".gif"))
    ) {
      return true;
    }
    return false;
  }

  /**
   * Deletes a file from a url.
   *
   * It will also delete thumbnail image if it exists.
   *
   * @param url url of the file(or image)
   * @returns
   *  - true on success,
   *  - false if there is nothing to delete
   *  - Exception will be thrown on error.
   */
  static async deleteFileFromUrl(url: string): Promise<boolean> {
    // If it's not a file from firebase storage, it does not do anything.
    if (this.isFirebaseStorageUrl(url) === false) return false;

    if (url.startsWith("http") === false) return false;

    const file = this.getRefFromUrl(url);
    const isExists = await file.exists();
    if (isExists[0]) await file.delete();

    // if that is the original url.
    if (this.isImageUrl(url)) {
      // delete associating thumbnail url.
      const thumbnailUrl = this.getThumbnailUrl(url);
      const thumbFile = this.getRefFromUrl(thumbnailUrl);
      const thumbExists = await thumbFile.exists();
      if (thumbExists[0]) await thumbFile.delete();
    }

    return true;
  }

  // / Return true if the message is a URL of uploaded file in Firebase Storage.
  static isFirebaseStorageUrl(url: string): boolean {
    return url.includes("storage.googleapis.com");
  }

  /**
   *
   * @param path path of the file to be uploaded. For instance "./tests/storage/test.jpg"
   * @param filename file name to be saved in firebase storage. it should have folder naem also.
   *  For instance, "uploads/abc-1234.jpg"
   * @returns File object as described at https://googleapis.dev/nodejs/storage/latest/File.html
   */
  static async upload(path: string, filename: string) {
    const bucket = admin.storage().bucket();
    const res = await bucket.upload(path, { destination: filename });
    return res[0];
  }
}
