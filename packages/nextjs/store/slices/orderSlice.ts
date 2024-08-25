import { PayloadAction, createSlice } from "@reduxjs/toolkit";

interface Product {
  name: string;
  quantity: number;
  price: number;
}

interface Order {
  id: number;
  restaurant: string;
  restaurantImage: string; // Imagen del restaurante
  address: string; // Dirección del restaurante
  products: Product[];
  deliveryFee: number;
  isAccepted: boolean; // Nueva propiedad para indicar si la orden es aceptada o no
}

interface OrderState {
  order: Order | null;
}

const initialState: OrderState = {
  order: null,
};

const orderSlice = createSlice({
  name: "order",
  initialState,
  reducers: {
    setOrder: (state, action: PayloadAction<Order>) => {
      state.order = action.payload;
    },
    clearOrder: state => {
      state.order = null;
    },
    updateProductQuantity: (state, action: PayloadAction<{ index: number; quantity: number }>) => {
      if (state.order) {
        state.order.products[action.payload.index].quantity = action.payload.quantity;
      }
    },
    setOrderAccepted: (state, action: PayloadAction<boolean>) => {
      if (state.order) {
        state.order.isAccepted = action.payload;
      }
    },
  },
});

export const { setOrder, clearOrder, updateProductQuantity, setOrderAccepted } = orderSlice.actions;
export default orderSlice.reducer;
