export default {
  providers: [
    {
      domain: process.env.AUTH0_DOMAIN!,
      applicationID: process.env.AUTH0_APPLICATION_ID!,
      // JWT audience must match Convex deployment for token verification
    },
  ],
};
