import React, { createContext, useState, useEffect } from 'react';

export const CartContext = createContext();

export const CartProvider = ({ children }) => {
  const [items, setItems] = useState([]);

  // Load cart from localStorage on mount
  useEffect(() => {
    const stored = localStorage.getItem('cart');
    if (stored) setItems(JSON.parse(stored));
  }, []);

  // Persist cart changes
  useEffect(() => {
    localStorage.setItem('cart', JSON.stringify(items));
  }, [items]);

  const addItem = (product, quantity = 1) => {
    setItems((prev) => {
      const existing = prev.find((i) => i.id === product.id);
      if (existing) {
        return prev.map((i) =>
          i.id === product.id ? { ...i, quantity: i.quantity + quantity } : i
        );
      }
      return [...prev, { ...product, quantity }];
    });
  };

  const removeItem = (productId) => {
    setItems((prev) => prev.filter((i) => i.id !== productId));
  };

  const clearCart = () => setItems([]);

  const totalPrice = () =>
    items.reduce((sum, i) => sum + i.price * i.quantity, 0);

  // Assuming platform fee is 2% of total and wholesale price is stored in product.wholesalePrice
  const totalSavings = () =>
    items.reduce(
      (sum, i) =>
        sum +
        (i.price - (i.wholesalePrice || i.price)) * i.quantity,
      0
    );

  return (
    <CartContext.Provider
      value={{ items, addItem, removeItem, clearCart, totalPrice, totalSavings }}
    >
      {children}
    </CartContext.Provider>
  );
};
