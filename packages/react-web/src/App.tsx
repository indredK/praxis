import React, { useState } from "react";
import { Tabs } from "antd";
import Demo1 from "./page/demo1";
import Demo2 from "./page/demo2";
import "./App.css";

function App() {
  const [activeTab, setActiveTab] = useState("demo1");

  const tabItems = [
    {
      key: "demo1",
      label: "Demo 1",
      children: <Demo1 />,
    },
    {
      key: "demo2",
      label: "Demo 2",
      children: <Demo2 />,
    },
  ];

  return (
    <div
      style={{
        height: "100vh",
        width: "100vw",
        margin: 0,
        padding: 0,
        display: "flex",
        flexDirection: "column",
      }}
    >
      <div
        style={{
          padding: "16px 24px",
          borderBottom: "1px solid #f0f0f0",
          backgroundColor: "#fff",
        }}
      >
        <h1 style={{ margin: 0, fontSize: "24px", fontWeight: "bold" }}>
          单页面多Tab应用
        </h1>
      </div>
      <div
        style={{
          flex: 1,
          padding: "24px",
          overflow: "auto",
          backgroundColor: "#f5f5f5",
        }}
      >
        <Tabs
          activeKey={activeTab}
          onChange={setActiveTab}
          items={tabItems}
          size="large"
          style={{ height: "100%" }}
          tabBarStyle={{ marginBottom: 0 }}
        />
      </div>
    </div>
  );
}

export default App;
