[题目地址](https://leetcode.cn/problems/path-sum-i/)

这题正常递归，很简单不必多少。
我第一遍就写出来了。以为只要有就行了。没有的根节点返回false。
只要有一个根节点true。最后的结果一定是对的。
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
    public boolean hasPathSum(TreeNode root, int targetSum) {
        if (root == null) {
            return false;
        }
        if (root.val == targetSum && root.left == null && root.right == null) {
            return true;
        }
        boolean a = hasPathSum(root.left, targetSum - root.val);
        boolean b = hasPathSum(root.right, targetSum - root.val);
        return a || b;
    }

}
```
