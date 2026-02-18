[题目地址](https://leetcode.cn/problems/jump-game-ii/)

关键就在找出覆盖范围中能跳的最远的。每次跳跃跳到这个潜力最大的上面 总的就跳的最少。

```java
class Solution {
    public int jump(int[] nums) {
        if (nums.length == 1) {
            return 0;
        }
        int res = 0;
        int len = 0;
        int end = 0;
        for (int i = 0; i < nums.length; i++) {
            len = Math.max(nums[i] + i, len);
            if (i == end) {
                res++;
                end = len;
                if (len >= nums.length - 1) {
                    break;
                }
            }
        }
        return res;
    }
}
```
