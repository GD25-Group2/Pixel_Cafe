# Decision Log

## Prototype Below
### Date
- Decision No.: How many decisions have been made by the maker in this date.
- Decision Description: Must be detail and persuasive.
- Decision Maker:
- Status: Either Pending, Approved or Superceded. To Note, decisions are not to be implement until approved by other members.

### 2026-04-21
- Decision No.: 1
- Decision Description: Mouse checking condition to be written in a way that all other game states can use it.
- Decision Maker: Kyaw Sis Thway
- Status: Pending

### 2026-06-08
- Decision No.: 2
- Decision Description: Add a chopping board that can handle both vegetable and meat outputting respective slices. Modify the coffee machine so that the animation of coffee machine is not changing the whole machine but just a part of it like the jar. Just animate the jar animation layering above the machine. Change the BaseState's mouseResponse function to use Signal to reduce complexity and scalability.
Change the day start shop to stop using randomly placing items and instead use a structure similar to shop menu. Also do the two issues. Only after that update the branch. Add money gained stack table that will record the sale of that day and at the day end state, show each item sold adding up to total money.
Add streak system, which will give higher percent of bonus money and patience to the following customer.
The streak system will also have negative streak, that reduce the patience of the following customer. Currently, the customer patience is too long, reduce it. At the closing state, show the items still in preparation stage, being abandoned in the trash bin at the same time as the customer leave. Make the stove not a drag machine but a click machine just like the coffee machine.
- Decision Maker: Kyaw Sis Thway
- Status: Pending