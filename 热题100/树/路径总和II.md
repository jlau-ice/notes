[题目地址](https://leetcode.cn/problems/path-sum-ii/)

一开始写的有问题，list没有清，而且存的是引用类型，导致返回的结果都是一样的
存结果的时候要拷贝一个副本。
注意点就是这里，
然后还有一个就是。回溯的时候要把自己删了。不然会影响其他路径。
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
    List<List<Integer>> res = new ArrayList<>();

    public List<List<Integer>> pathSum(TreeNode root, int targetSum) {
        List<Integer> l = new ArrayList<>();
        listAdd(root, targetSum, l);
        return res;
    }

    public void listAdd(TreeNode root, int targetSum, List<Integer> list) {
        if (root == null) {
            return;
        }
        list.add(root.val);
        if (root.left == null && root.right == null) {
            if (root.val == targetSum) {
                res.add(new ArrayList<>(list));
            }
        } else {
            listAdd(root.left, targetSum - root.val, list);
            listAdd(root.right, targetSum - root.val, list);
        }
        list.remove(list.size() - 1);
    }
}
```

