import { CollectionConfig } from "payload/types";

const Press: CollectionConfig = {
  slug: "press",
  admin: {
    useAsTitle: "title",
    defaultColumns: ["title", "date", "priority"],
  },
  labels: {
    singular: "Press Article",
    plural: "Press Articles",
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
      name: "publisher",
      type: "text",
      required: true,
      admin: {
        description: "e.g. Süddeutsche Zeitung, Der Spiegel, etc.",
      },
    },
    {
      name: "date",
      type: "date",
      admin: {
        position: "sidebar",
      },
    },
    {
      name: "thumbnail",
      type: "upload",
      relationTo: "media",
      required: true,
      admin: {
        description: "Thumbnail image for the press item",
      },
    },
    {
      name: "pressType",
      type: "select",
      defaultValue: "pdf",
      required: true,
      options: [
        {
          label: "PDF Document",
          value: "pdf",
        },
        {
          label: "Video Embed",
          value: "video",
        },
      ],
      admin: {
        description: "Choose the type of press content",
      },
    },
    {
      name: "pdfDocument",
      type: "upload",
      relationTo: "documents",
      required: false,
      admin: {
        condition: (data) => data.pressType === "pdf",
        description: "Upload a PDF document",
      },
    },
    {
      name: "videoUrl",
      type: "text",
      required: false,
      admin: {
        condition: (data) => data.pressType === "video",
        description: "Video URL (YouTube, Vimeo, etc.)",
      },
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
  ],
};

export default Press; 