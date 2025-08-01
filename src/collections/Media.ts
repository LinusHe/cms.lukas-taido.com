import { CollectionConfig } from "payload/types";

const MEDIA_PATH = process.env.MEDIA_DIR || "../../media";
const Media: CollectionConfig = {
  slug: "media",
  fields: [],
  access: {
    read: () => true,
  },
  upload: {
    staticURL: "/media",
    staticDir: MEDIA_PATH,
    imageSizes: [
      {
        name: "thumbnail",
        width: 400,
        height: 300,
        position: "centre",
      },
      {
        name: "card",
        width: 768,
        height: 1024,
        position: "centre",
      },
      {
        name: "tablet",
        width: 1024,
        // By specifying `undefined` or leaving a height undefined,
        // the image will be sized to a certain width,
        // but it will retain its original aspect ratio
        // and calculate a height automatically.
        height: undefined,
        position: "centre",
      },
    ],
    adminThumbnail: "thumbnail",
    mimeTypes: ["image/*"],
  },
};

export default Media;
