# Regression summary

| Run | Seed | Txns | Pass | Fail | Assert fails | Opcode coverage | ADD | SUB | AND | OR | XOR | SHL | SHR | PASS |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| seed_1 | 1 | 20 | 20 | 0 | 0 | 7/8 | 2 | 4 | 4 | 2 | 1 | 0 | 1 | 6 |
| seed_2 | 2 | 20 | 20 | 0 | 0 | 7/8 | 0 | 3 | 1 | 2 | 4 | 6 | 2 | 2 |
| seed_3 | 3 | 20 | 20 | 0 | 0 | 8/8 | 1 | 4 | 4 | 3 | 2 | 2 | 1 | 3 |
| seed_4 | 4 | 20 | 20 | 0 | 0 | 8/8 | 3 | 2 | 6 | 1 | 2 | 3 | 1 | 2 |
| seed_5 | 5 | 20 | 20 | 0 | 0 | 7/8 | 1 | 2 | 2 | 0 | 4 | 3 | 5 | 3 |
| seed_6 | 6 | 20 | 20 | 0 | 0 | 8/8 | 2 | 2 | 3 | 5 | 1 | 1 | 2 | 4 |
| seed_7 | 7 | 20 | 20 | 0 | 0 | 5/8 | 6 | 0 | 0 | 4 | 0 | 5 | 2 | 3 |
| seed_8 | 8 | 20 | 20 | 0 | 0 | 6/8 | 3 | 5 | 0 | 2 | 4 | 2 | 4 | 0 |
| seed_9 | 9 | 20 | 20 | 0 | 0 | 8/8 | 3 | 3 | 2 | 1 | 2 | 4 | 3 | 2 |
| seed_10 | 10 | 20 | 20 | 0 | 0 | 8/8 | 1 | 1 | 7 | 2 | 3 | 2 | 2 | 2 |
| bug_injected | 42 | 200 | 183 | 17 | 17 | 8/8 | 35 | 25 | 19 | 27 | 20 | 34 | 23 | 17 |
| long_1000 | 42 | 1000 | 1000 | 0 | 0 | 8/8 | 140 | 122 | 120 | 117 | 113 | 119 | 139 | 130 |

Clean-ALU runs: 11, transactions: 1200, pass: 1200, fail: 0, assertion failures: 0. Runs with all 8 opcodes covered: 6/11.
Opcode totals over clean runs: ADD=162, SUB=148, AND=149, OR=139, XOR=136, SHL=147, SHR=162, PASS=157.

First failures caught in the bug-injection run:

- `bug_injected: A=15 B=15 opcode=5 result=15 -> Expected=14 Got=15`
- `bug_injected: A=15 B=15 opcode=5 result=15 -> Expected=14 Got=15`
- `bug_injected: A=9 B=3 opcode=5 result=3 -> Expected=2 Got=3`
- `bug_injected: A=13 B=15 opcode=5 result=11 -> Expected=10 Got=11`
- `bug_injected: A=15 B=15 opcode=5 result=15 -> Expected=14 Got=15`
