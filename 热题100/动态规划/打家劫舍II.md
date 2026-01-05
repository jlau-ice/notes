[题目地址](https://leetcode.cn/problems/house-robber-ii/)

拆分成两个普通的打家劫舍

```java
class Solution {
    public int rob(int[] nums) {
        if (nums.length == 1) {
            return nums[0];
        }
        if (nums.length == 2) {
            return Math.max(nums[0], nums[1]);
        }
        return Math.max(dpSearch(nums, 0, nums.length - 1), dpSearch(nums, 1, nums.length));
    }

    private int dpSearch(int[] nums, int start, int end) {
        if (end - start == 1) {
            return nums[start];
        }
        if (end - start == 2) {
            return Math.max(nums[start + 1], nums[start]);
        }
        int[] dp = new int[nums.length];
        dp[start] = nums[start];
        dp[start + 1] = Math.max(nums[start], nums[start + 1]);
        for (int i = start + 2; i < end; i++) {
            dp[i] = Math.max(dp[i - 1], dp[i - 2] + nums[i]);
        }
        return dp[end - 1];
    }
}
```