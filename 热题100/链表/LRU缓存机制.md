思路看了题解倒是很清晰
构建一个哈希表和一个双向链表
get 没有返回 -1 有则将 节点移动到头部

put 如果存在相同的key，更新值，并移动到前面。

如果不存在则构建一个新的。
放到链表最前面，如果容量超了，则需要移除尾部。


```java
class LRUCache {

    class Node {
        private int val;
        private int key;
        private Node next;
        private Node pre;

        public Node() {
        }

        public Node(int val, int key) {
            this.val = val;
            this.key = key;
        }
    }

    private Map<Integer, Node> map;

    private int capacity;

    private Node head;

    private Node tail;

    public LRUCache(int capacity) {
        this.capacity = capacity;
        map = new HashMap<>(capacity);
        head = new Node();
        tail = new Node();
        head.next = tail;
        tail.pre = head;
    }

    public int get(int key) {
        Node node = map.get(key);
        if (node == null) {
            return -1;
        }
        moveToHead(node);
        return node.val;
    }

    public void put(int key, int value) {
        Node node = new Node(value, key);
        if (map.size() < capacity) {
            if (map.containsKey(key)) {
                Node exisNode = map.get(key);
                exisNode.val = value;
                // 移动到头部
                moveToHead(exisNode);
            } else {
                map.put(key, node);
                addHead(node);
            }
        } else {
            if (map.containsKey(key)) {
                Node exisNode = map.get(key);
                exisNode.val = value;
                // 移动到头部
                moveToHead(exisNode);
            } else {
                map.put(key, node);
                // 删除
                Node tailNode = removeTail();
                map.remove(tailNode.key);
                addHead(node);
            }
        }
    }

    public void removeNode(Node node) {
        node.pre.next = node.next;
        node.next.pre = node.pre;
    }

    public Node removeTail() {
        Node tailPre = tail.pre;
        removeNode(tailPre);
        return tailPre;
    }

    public void addHead(Node node) {
        Node headNext = head.next;
        headNext.pre = node;
        node.next = headNext;
        head.next = node;
        node.pre = head;
    }

    public void moveToHead(Node node) {
        removeNode(node);
        addHead(node);
    }
}

/**
 * Your LRUCache object will be instantiated and called as such:
 * LRUCache obj = new LRUCache(capacity);
 * int param_1 = obj.get(key);
 * obj.put(key,value);
 */
```
