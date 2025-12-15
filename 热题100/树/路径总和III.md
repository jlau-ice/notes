[题目地址](https://leetcode.cn/problems/path-sum-iii)

思路是 便利每和节点， 找每个节点的所有路径 等于target 的个数
需要递归两次
第一次递归是 递归便利每个节点

在每个节点遍历的是后去找这个节点所有路径为 target 的个数

整体代码
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
    public int pathSum(TreeNode root, long targetSum) {
        if (root == null) {
            return 0;
        }
        // 计算当前节点的所有路径，这个放哪都行，前中后序遍历的时候用来收集节点的list 一个作用。
        int count = curNodeTargetCount(root, targetSum);
        int lcount = pathSum(root.left, targetSum);
        int rcount = pathSum(root.right, targetSum);
        return lcount + rcount + count;
    }

    // 这个是核心方法，用来计算当前节点为起点 的 有几个加起来可以 凑够 targetSum
    private int curNodeTargetCount(TreeNode node, long targetSum) {
        if (node == null) {
            return 0;
        }
        int l = curNodeTargetCount(node.left, targetSum - node.val);
        int r = curNodeTargetCount(node.right, targetSum - node.val);
        return (node.val == targetSum ? 1 : 0) + l + r;
    }
}
```
