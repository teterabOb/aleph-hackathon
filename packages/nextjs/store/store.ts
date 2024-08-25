// src/store/store.ts
import { configureStore, combineReducers } from "@reduxjs/toolkit";
import { persistStore, persistReducer } from "redux-persist";
import storage from "redux-persist/lib/storage";
import orderReducer from "./slices/orderSlice"; // Importa el slice de la orden
import riderReducer from "./slices/riderSlice";

const rootReducer = combineReducers({
  order: orderReducer,
  rider: riderReducer,
  // otros reducers...
});

const persistConfig = {
  key: "root",
  storage,
  whitelist: ["order", "rider"], // Persiste el estado de la orden si lo necesitas
};

const persistedReducer = persistReducer(persistConfig, rootReducer);

export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [
          "persist/PERSIST",
          "persist/REHYDRATE",
          "persist/REGISTER",
          "persist/PURGE",
        ],
      },
    }),
});

export const persistor = persistStore(store);
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
