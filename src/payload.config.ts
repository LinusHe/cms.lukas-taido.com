import { buildConfig } from "payload/config";
import path from "path";
// import Examples from './collections/Examples';
import Users from "./collections/Users";
import Tags from "./collections/Tags";
import Projects from "./collections/Projects";
import Media from "./collections/Media";
import Press from "./collections/Press";
import Documents from "./collections/Documents";
import Global from "./globals/Global";
import Impressum from "./globals/Impressum";

export default buildConfig({
  // serverURL fucks up the build
  // serverURL: process.env.PAYLOAD_PUBLIC_SERVER_URL || "http://localhost:3001",

  admin: {
    user: Users.slug,
    meta: {
      favicon: "/assets/favicon.ico",
    },
  },
  cors: ["http://localhost:3000", "https://www.lukas-taido.com", "https://lukas-taido.com"],
  collections: [
    Users,
    Tags,
    Projects,
    Media,
    Documents,
    Press,
    // Add Collections here
    // Examples,
  ],
  globals: [Global, Impressum],
  typescript: {
    outputFile: path.resolve(__dirname, "payload-types.ts"),
  },
  graphQL: {
    schemaOutputFile: path.resolve(__dirname, "generated-schema.graphql"),
  },
});
