/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as auth_auth from "../auth/auth.js";
import type * as auth_rbac from "../auth/rbac.js";
import type * as cron from "../cron.js";
import type * as mutations_auditLog from "../mutations/auditLog.js";
import type * as mutations_cabinets from "../mutations/cabinets.js";
import type * as mutations_events from "../mutations/events.js";
import type * as mutations_generatorSettings from "../mutations/generatorSettings.js";
import type * as mutations_payments from "../mutations/payments.js";
import type * as mutations_subscribers from "../mutations/subscribers.js";
import type * as mutations_trash from "../mutations/trash.js";
import type * as mutations_whatsappTemplates from "../mutations/whatsappTemplates.js";
import type * as mutations_workers from "../mutations/workers.js";
import type * as queries_auditLog from "../queries/auditLog.js";
import type * as queries_cabinets from "../queries/cabinets.js";
import type * as queries_events from "../queries/events.js";
import type * as queries_generatorSettings from "../queries/generatorSettings.js";
import type * as queries_payments from "../queries/payments.js";
import type * as queries_subscribers from "../queries/subscribers.js";
import type * as queries_trash from "../queries/trash.js";
import type * as queries_whatsappTemplates from "../queries/whatsappTemplates.js";
import type * as queries_workers from "../queries/workers.js";
import type * as utils_functions from "../utils/functions.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

declare const fullApi: ApiFromModules<{
  "auth/auth": typeof auth_auth;
  "auth/rbac": typeof auth_rbac;
  cron: typeof cron;
  "mutations/auditLog": typeof mutations_auditLog;
  "mutations/cabinets": typeof mutations_cabinets;
  "mutations/events": typeof mutations_events;
  "mutations/generatorSettings": typeof mutations_generatorSettings;
  "mutations/payments": typeof mutations_payments;
  "mutations/subscribers": typeof mutations_subscribers;
  "mutations/trash": typeof mutations_trash;
  "mutations/whatsappTemplates": typeof mutations_whatsappTemplates;
  "mutations/workers": typeof mutations_workers;
  "queries/auditLog": typeof queries_auditLog;
  "queries/cabinets": typeof queries_cabinets;
  "queries/events": typeof queries_events;
  "queries/generatorSettings": typeof queries_generatorSettings;
  "queries/payments": typeof queries_payments;
  "queries/subscribers": typeof queries_subscribers;
  "queries/trash": typeof queries_trash;
  "queries/whatsappTemplates": typeof queries_whatsappTemplates;
  "queries/workers": typeof queries_workers;
  "utils/functions": typeof utils_functions;
}>;

/**
 * A utility for referencing Convex functions in your app's public API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, "public">
>;

/**
 * A utility for referencing Convex functions in your app's internal API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = internal.myModule.myFunction;
 * ```
 */
export declare const internal: FilterApi<
  typeof fullApi,
  FunctionReference<any, "internal">
>;

export declare const components: {};
