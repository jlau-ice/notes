[题目地址](https://leetcode.cn/problems/house-robber-iii/description/)

一定要后续，选择当前节点 就不能选 孩子
每个节点有两种值
选当前节点 就不能选孩子啊 
不选当前节点，选左右孩子能的到的最大值。

```java
/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode() {}
 *     TreeNode(int val) { this.val = val; }
 *     TreeNode(int val, TreeNode left, TreeNode right) {
 *         this.val = val;
 *         this.left = left;
 *         this.right = right;
 *     }
 * }
 */
class Solution {
    public int rob(TreeNode root) {
        int[] dfs = dfs(root);
        return Math.max(dfs[0], dfs[1]);
    }

    // [0] 表示 不选择 当前节点 
    // [1] 表示选择当前节点
    public int[] dfs(TreeNode root) {
        if (root == null) {
            return new int[] { 0, 0 };
        }
        int[] l = dfs(root.left);
        int[] r = dfs(root.right);
        // 要当前节点
        int a = l[0] + r[0] + root.val;
        // 不要当前节点，就去选择左右孩子的最大值。
        int b = Math.max(l[0], l[1]) + Math.max(r[0], r[1]);
        return new int[] { b, a };
    }
}
```