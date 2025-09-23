import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { Button } from "./Button";

describe("Button Component - Functional & Logical Tests", () => {
  /**
   * Test Case 1: Verifies default rendering without any special props.
   */
  it("should render with default props and the correct label", () => {
    // Arrange: Render the component with a label
    render(<Button label="Click Me" />);

    // Act: Find the button in the rendered DOM
    const buttonElement = screen.getByRole("button", { name: /click me/i });

    // Assert: Check if it exists and has the correct default classes
    expect(buttonElement).toBeInTheDocument();
    expect(buttonElement).toHaveClass("storybook-button");
    expect(buttonElement).toHaveClass("storybook-button--medium"); // default size
    expect(buttonElement).toHaveClass("storybook-button--secondary"); // default mode
  });

  /**
   * Test Case 2: Verifies the `primary` prop logic.
   */
  it("should apply the primary class when the primary prop is true", () => {
    // Arrange
    render(<Button primary label="Primary Action" />);

    // Act
    const buttonElement = screen.getByRole("button", { name: /primary action/i });

    // Assert
    expect(buttonElement).toHaveClass("storybook-button--primary");
    expect(buttonElement).not.toHaveClass("storybook-button--secondary");
  });

  /**
   * Test Case 3: Verifies the `size` prop logic.
   */
  it("should apply the correct size class based on the size prop", () => {
    // Arrange
    render(<Button size="large" label="Large Button" />);

    // Act
    const buttonElement = screen.getByRole("button", { name: /large button/i });

    // Assert
    expect(buttonElement).toHaveClass("storybook-button--large");
    expect(buttonElement).not.toHaveClass("storybook-button--medium");
  });

  /**
   * Test Case 4: Verifies that style props are passed correctly.
   */
  it("should apply inline styles for backgroundColor", () => {
    // Arrange
    render(<Button backgroundColor="red" label="Red Button" />);

    // Act
    const buttonElement = screen.getByRole("button", { name: /red button/i });

    // Assert
    expect(buttonElement).toHaveStyle({ backgroundColor: "red" });
  });
});
