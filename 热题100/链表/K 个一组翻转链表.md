[题目地址](https://leetcode.cn/problems/reverse-nodes-in-k-group)

这题是个hard，但是我感觉如果用`O(N)`的空间的话只能算中等题目。
思路非常简单，k个分组，每组反转。如果允许`O(N)`,把每段存起来，遍历每小段进行一次反转，再拼接就好了。虽然写的很长但是思路很清晰。

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode() {}
 *     ListNode(int val) { this.val = val; }
 *     ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */
class Solution {
    public ListNode reverseKGroup(ListNode head, int k) {
        // 思路 k 个一反转，直到不足k
        List<ListNode> list = new ArrayList<>();
        int n = 1;
        ListNode newHead = head;
        ListNode cursor = head;
        while (cursor != null) {
            if (n % k == 0) {
                list.add(newHead);
                newHead = cursor.next;
                cursor.next = null;
                cursor = newHead;
            } else {
                cursor = cursor.next;
            }
            n++;
        }
        ListNode dummy = new ListNode();
        ListNode cur = dummy;
        for (ListNode part : list) {
            ListNode[] node = reversal(part);
            ListNode shead = node[0];
            ListNode tail = node[1];
            cur.next = shead;
            cur = tail;
        }
        if(newHead != null) {
            cur.next = newHead;
        }
        return dummy.next;
    }

    private ListNode[] reversal(ListNode head) {
        if (head == null || head.next == null) {
            return new ListNode[]{head,head};
        }
        ListNode pre = null;
        ListNode cur = head;
        while (cur != null) {
            ListNode next = cur.next;
            cur.next = pre;
            pre = cur;
            cur = next;
        }
        return new ListNode[] { pre, head };
    }

}
```

我们再想想有没有能用`O(1)`空间的写法。emmm，想不出来，看题解用模拟。

