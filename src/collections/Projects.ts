import { CollectionConfig } from "payload/types";

// Example Collection - For reference only, this must be added to payload.config.ts to be used.
const Projects: CollectionConfig = {
  slug: "projects",
  admin: {
    useAsTitle: "title",
    defaultColumns: ["title", "date", "priority", "tags"],
  },
  versions: {
    drafts: {
      autosave: true,
    },
  },
  access: {
    read: ({ req }) => {
      // If there is a user logged in,
      // let them retrieve all documents
      if (req.user) return true;

      // If there is no user,
      // restrict the documents that are returned
      // to only those where `_status` is equal to `published`
      // or where `_status` does not exist
      return {
        or: [
          {
            _status: {
              equals: "published",
            },
          },
          {
            _status: {
              exists: false,
            },
          },
        ],
      };
    },
    admin: () => true,
  },
  fields: [
    {
      name: "title",
      type: "text",
      required: true,
    },
    {
      name: "date",
      type: "date",
      admin: {
        position: "sidebar",
      },
    },
    {
      name: "teaserImage",
      type: "upload", // required
      relationTo: "media", // required
      required: false,
    },
    {
      name: "tags",
      type: "relationship",
      relationTo: "tags",
      hasMany: true,
      admin: {
        position: "sidebar",
      },
    },
    {
      name: "content",
      type: "richText",
    },
    {
      name: "legacyId",
      type: "number",
      hidden: true,
    },
    {
      name: "priority",
      type: "number",
      defaultValue: 1,
      required: true,
      admin: {
        position: "sidebar",
        description:
          "The higher the number, the closer to the top of the list.",
      },
    },
    {
      name: "videos",
      type: "array",
      fields: [
        {
          name: "vimeoUrl",
          type: "text",
          required: true,
          admin: {
            description:
              "The URL of the Vimeo video, e.g. https://vimeo.com/123456789",
          },
        },
        {
          name: "caption",
          type: "text",
        },
      ],
    },
    {
      name: "images",
      type: "array",
      fields: [
        {
          name: "image",
          type: "upload",
          required: true,
          relationTo: "media",
        },
        {
          name: "caption",
          type: "text",
        },
        {
          name: "maxWidth",
          type: "number",
          admin: {
            description:
              "Optional: Maximum width in pixels. Leave empty for full width. Useful for smaller images like newspaper clippings.",
          },
        },
      ],
    },
  ],
};

export default Projects;
