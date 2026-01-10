[题目地址](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/)
和一一模一样

```java
class Solution {
    public int maxProfit(int[] prices) {
        int[][] dp = new int[prices.length + 1][2];
        dp[0][0] = Integer.MIN_VALUE;
        int res = 0;
        for (int i = 1; i <= prices.length; i++) {
            dp[i][0] = Math.max(dp[i - 1][0], dp[i - 1][1] - prices[i - 1]);
            dp[i][1] = Math.max(prices[i - 1] + dp[i][0], dp[i - 1][1]);
            res = Math.max(res, dp[i][1]);
        }
        return res;
    }
}
```
