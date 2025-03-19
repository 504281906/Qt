import QtQuick 2.12
import QtQuick.Controls 2.12

ApplicationWindow {
    visible: true
    width: 500
    height: 500
    title: "2048 Game"
    // 设置最大宽度和高度，防止全屏
    maximumWidth: 500
    maximumHeight: 500
    property var choice:([])
    // 颜色定义
    property var tileColors: ({
        2: "#EEE4DA", 4: "#EDE0C8", 8: "#F2B179",
        16: "#F59563", 32: "#F67C5F", 64: "#F65E3B",
        128: "#EDCF72", 256: "#EDCC61", 512: "#EDC850",
        1024: "#EDC53F", 2048: "#EDC22E"
    })

    // 4x4 游戏网格
    property var grid: [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ]

    // 窗口主体
    Rectangle {
        id: gameArea
        width: 405
        height: 405
        color: "#BBADA0"
        anchors.centerIn: parent
        focus: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left) moveTiles("left");
            else if (event.key === Qt.Key_Right) moveTiles("right");
            else if (event.key === Qt.Key_Up) moveTiles("up");
            else if (event.key === Qt.Key_Down) moveTiles("down");
        }

        // 绘制 16 个方格
        Repeater {
            model: 16
            Rectangle {
                width: 85
                height: 85
                radius: 5
                color: "#CDC1B4"
                border.color: "#BBADA0"
                x: (index % 4) * 100 + 10
                y: Math.floor(index / 4) * 100 + 10
            }
        }

        // 显示数字方块
        Repeater {
            id: gameBorder
            model: 16
            Rectangle {
                width: 85
                height: 85
                radius: 5
                color: grid[Math.floor(index / 4)][index % 4] ? tileColors[grid[Math.floor(index / 4)][index % 4]] : "transparent"
                x: (index % 4) * 100 + 10
                y: Math.floor(index / 4) * 100 + 10

                Text {
                    anchors.centerIn: parent
                    text: grid[Math.floor(index / 4)][index % 4] === 0 ? "" : grid[Math.floor(index / 4)][index % 4]
                    font.pixelSize: 24
                    font.bold: true
                    color: "black"
                }
            }
        }
    }

    // 重新开始按钮
    Button {
        text: "Restart"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            resetGame();
            gameArea.forceActiveFocus(); // ✅ 让窗口重新获取焦点，方向键生效
        }
    }

    // 游戏逻辑
    Component.onCompleted:
    {
        resetGame();
    }

    function resetGame() {
        for (var i = 0; i < 4; i++) {
            for (var j = 0; j < 4; j++) {
                grid[i][j] = 0;
            }
        }
        addRandomTile();
        addRandomTile();
    }

    function addRandomTile() {
        var emptyTiles = [];
        for (var i = 0; i < 4; i++) {
            for (var j = 0; j < 4; j++) {
                if (grid[i][j] === 0) {
                    emptyTiles.push({ row: i, col: j });
                }
            }
        }
        var item = gameBorder.itemAt(choice.row * 4 + choice.col);
        if (item)
        {
            console.info(item.border.color);
            item.border.color = "transparent";
        }
        if (emptyTiles.length > 0) {
            choice = emptyTiles[Math.floor(Math.random() * emptyTiles.length)];
            grid[choice.row][choice.col] = Math.random() < 0.8 ? 2 : 4;
        }

        item = gameBorder.itemAt(choice.row * 4 + choice.col);
        if (item)
        {
            item.border.color = "red";
        }

        grid = grid.slice();
    }

    function moveTiles(direction) {
        var moved = false;
        var newGrid = [[], [], [], []];

        for (var i = 0; i < 4; i++) {
            var line = [];
            for (var j = 0; j < 4; j++) {
                var value = (direction === "left" || direction === "right") ? grid[i][j] : grid[j][i];
                if (value !== 0) {
                    line.push(value);
                }
            }

            // 合并相同数字
            if (direction === "down" || direction === "right")
            {
                for (var k = line.length - 1; k > 0; k--) {
                    if (line[k] === line[k - 1]) {
                        line[k] *= 2;
                        line.splice(k - 1, 1);
                    }
                }
            }
            else
            {
                for (var k = 0; k < line.length - 1; k++) {
                    if (line[k] === line[k + 1]) {
                        line[k] *= 2;
                        line.splice(k + 1, 1);
                    }
                }
            }



            // **填充 0（对齐方式根据方向调整）**
            while (line.length < 4) {
            if (direction === "right" || direction === "down") {
                line.unshift(0);  // 右/下填充到前面
            } else {
                line.push(0);  // 左/上填充到后面
                }
            }

            // 更新 newGrid
            for (var j = 0; j < 4; j++) {
                if (direction === "left") {
                    newGrid[i][j] = line[j];
                } else if (direction === "right") {
                    newGrid[i][j] = line[j];
                } else if (direction === "up") {
                    newGrid[j][i] = line[j];
                } else if (direction === "down") {
                    newGrid[j][i] = line[j];
                }
            }
        }
//        console.info("grid:" + grid);
//        console.info("newgrid:" + newGrid);
        if (grid.toString() !== newGrid.toString())
        {
            // 更新 grid
            grid = newGrid;
            moved = true;
        }

//        console.info(moved);
        if (moved) {
            addRandomTile();
        }
        else{
            checkGameOver();
        }
    }

    function checkGameOver() {
        for (var i = 0; i < 4; i++) {
            for (var j = 0; j < 4; j++) {
                if (grid[i][j] === 0) return;
                if (j < 3 && grid[i][j] === grid[i][j + 1]) return;
                if (i < 3 && grid[i][j] === grid[i + 1][j]) return;
            }
        }
        console.log("Game Over!");
    }
}
