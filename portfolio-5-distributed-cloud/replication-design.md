# Portfolio 5 — Distributed and Cloud Database Exercise

## Proposed deployment

Comfort Private Hospital's appointment system would use a PostgreSQL
primary server and a standby server in separate cloud availability
zones. The primary would handle appointment bookings, cancellations,
and availability checks. The standby would receive changes through
asynchronous streaming replication and serve read-only reports that
can tolerate a delay.

## Replication lag and booking consistency

In Portfolio 3, I used two sessions to test whether staff could book
the same clinician for the 09:00 slot. One booking committed, and
PostgreSQL rejected the second because a partial unique index allows
only one appointment with status `booked` for the same clinician and
start time.

In the proposed deployment, the primary could confirm that booking
before the standby applies the change. During that delay, a report
reading from the standby could still show the slot as available.
The booking screen would therefore read availability from the primary
and send booking requests there.

Two staff members can still see the slot as available if both check
before either booking commits. The unique index enforces the rule when
they submit their bookings. Once one booking commits, PostgreSQL rejects
the conflicting insert.

## Availability and failover

If the primary fails, the standby can be promoted to accept writes.
The application would reconnect to the promoted server before resuming
bookings. With asynchronous replication, the primary can acknowledge
a booking before the standby receives it. If the primary fails during
that window, the confirmed booking may be missing from the promoted
server.

This design lets the primary confirm bookings without waiting for the
standby, but recent bookings can be lost during failover. It also lets
the standby serve reports, provided those reports can tolerate data
that is briefly out of date.

## Scope of the exercise

Portfolio 3 demonstrated the booking rule using two sessions on a
single PostgreSQL server. Portfolio 5 uses that observed result to
discuss how booking consistency and failover would work in a proposed
replicated deployment.

## References

- [PostgreSQL documentation — Streaming replication and standby servers](https://www.postgresql.org/docs/18/warm-standby.html)
- [PostgreSQL documentation — Read-only queries on a hot standby](https://www.postgresql.org/docs/18/hot-standby.html)
