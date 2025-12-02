二叉搜索树按照中序便利就是，完全从小到大的排列。
第k小，就从list 取出 第 k-1 的元素就行了。
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
    public int kthSmallest(TreeNode root, int k) {
        List<Integer> list = new ArrayList<>();
        mid(list, root);
        return list.get(k - 1);
    }

    public void mid(List<Integer> list, TreeNode root) {
        if (root == null) {
            return;
        }
        mid(list, root.left);
        list.add(root.val);
        mid(list, root.right);
    }
}
```


优化版本，找到之后直接停止，不用继续寻找了。
迭代法实现。
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
    public int kthSmallest(TreeNode root, int k) {
        Deque<TreeNode> stack = new ArrayDeque<>();
        stack.push(root);
        while (!stack.isEmpty() || root != null) {
            if(root != null) {
                stack.push(root);
                root = root.left;
            } else {
                TreeNode node = stack.pop();
                k--;
                if(k==0) {
                    return node.val;
                }
                root = node.right;
            }
        }
        return 0;
    }

    public void mid(List<Integer> list, TreeNode root) {
        if (root == null) {
            return;
        }
        mid(list, root.left);
        list.add(root.val);
        mid(list, root.right);
    }
}
```