'use strict';
const cds = require('@sap/cds');
const { SELECT, UPDATE, INSERT } = cds.ql;
/** Delivery is at least once. Receivers must deduplicate by immutable event ID. */
async function deliverBatch(db, publish, { limit=25, now=new Date(), maxAttempts=5 } = {}) {
 const rows = await db.run(SELECT.from('enterprise.IntegrationEvents').where({ status:'PENDING' }).limit(limit));
 let delivered = 0;
 for (const row of rows) {
  if (row.nextAttemptAt && new Date(row.nextAttemptAt) > now) continue;
  try {
   await publish({ id:row.ID, type:row.topic, data:JSON.parse(row.payload) });
   await db.run(UPDATE('enterprise.IntegrationEvents').set({ status:'DELIVERED', deliveredAt:now.toISOString() }).where({ ID:row.ID, status:'PENDING' }));
   delivered++;
  } catch {
   await db.tx(async tx => {
    const attempts = row.attempts + 1;
    const status = attempts >= maxAttempts ? 'DEAD' : 'PENDING';
    await tx.run(UPDATE('enterprise.IntegrationEvents').set({ attempts, status, nextAttemptAt:new Date(now.getTime()+Math.min(3600000,1000 * 2**attempts)).toISOString() }).where({ ID:row.ID, status:'PENDING' }));
    if (status === 'DEAD') await tx.run(INSERT.into('enterprise.DeadLetters').entries({ ID:cds.utils.uuid(), event_ID:row.ID, reason:'Delivery retry budget exhausted', resolved:false }));
   });
  }
 }
 return delivered;
}
module.exports = { deliverBatch };
