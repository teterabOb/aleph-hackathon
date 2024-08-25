import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface Product {
  name: string;
  quantity: number;
  price: number;
}

interface Order {
  id: number;
  restaurant: string;
  restaurantImage: string;
  address: string;
  products: Product[];
  deliveryFee: number;
  isAccepted: boolean;
}

interface RiderState {
  name: string;
  orders: Order[];
  isAvailable: boolean;
}

const initialState: RiderState = {
  name: "",
  orders: [],
  isAvailable: false, // Por defecto, el repartidor está disponible
};

const riderSlice = createSlice({
  name: "rider",
  initialState,
  reducers: {
    setRiderName: (state, action: PayloadAction<string>) => {
      state.name = action.payload;
    },
    addOrder: (state, action: PayloadAction<Order>) => {
      const existingOrder = state.orders.find(order => order.id === action.payload.id);
      if (!existingOrder) {
        state.orders.push(action.payload);
      }
    },
    clearOrders: (state) => {
      state.orders = [];
    },
    setAvailability: (state, action: PayloadAction<boolean>) => {
      state.isAvailable = action.payload;
    },
    acceptOrder: (state, action: PayloadAction<number>) => {
      const orderIndex = state.orders.findIndex(order => order.id === action.payload);
      if (orderIndex !== -1) {
        state.orders[orderIndex].isAccepted = true;
      }
    },
  },
});

export const { setRiderName, addOrder, clearOrders, setAvailability, acceptOrder } = riderSlice.actions;
export default riderSlice.reducer;
