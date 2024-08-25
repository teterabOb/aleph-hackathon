"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { clearOrder, setOrder } from "../../store/slices/orderSlice";
import { RootState } from "../../store/store";
import { GoogleMap, Libraries, Marker, useLoadScript } from "@react-google-maps/api";
import { MapPinIcon } from "lucide-react";
import type { NextPage } from "next";
import { useDispatch, useSelector } from "react-redux";
import { parseEther } from "viem";
import { Header } from "~~/components/Header";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth/useScaffoldWriteContract";

// Define el array de bibliotecas con el tipo correcto
const libraries: Libraries = ["places"];

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
  isAccepted: boolean;
}

const Checkout: NextPage = () => {
  const [order, setOrderState] = useState<Order | null>(null);
  const dispatch = useDispatch();
  const orderFromState = useSelector((state: RootState) => state.order.order);
  // payout(address businessAddress, uint256 amount, address destinationAddress, uint256 gasLimit)
  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract("DispatchCChain");

  const makeOrder = async () => {
    try {
      if (order) {
        // Actualizar el estado global de Redux con la orden
        dispatch(setOrder(order));
        console.log("Orden después de Payout:", orderFromState);
      }
      await writeYourContractAsync({
        functionName: "payout",
        args: [
          "0x1234567890123456789012345678901234567890",
          BigInt("1000"),
          "0x1234567890123456789012345678901234567890",
          BigInt(1000),
        ],
      });
    } catch (e) {
      console.error("Error setting greeting:", e);
    }
  };

  const mapContainerStyle = {
    width: "100%",
    height: "200px",
  };

  const center = {
    lat: -3.745,
    lng: -38.523,
  };

  const { isLoaded } = useLoadScript({
    googleMapsApiKey: "AIzaSyBBj2OwjYHibtANUHRFmuM-n7307E2Nauo",
    libraries, // Usa la constante `libraries` aquí
  });

  useEffect(() => {
    // Limpiar el estado de la orden en Redux al cargar el componente
    dispatch(clearOrder());

    // Cargar los datos iniciales de la orden en el estado local
    const initialOrder: Order = {
      id: 1,
      restaurant: "McDonald's",
      restaurantImage:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/McDonald%27s_Golden_Arches.svg/1200px-McDonald%27s_Golden_Arches.svg.png",
      address: "123 Main St, Springfield, USA",
      products: [
        { name: "Cheese Fries", quantity: 2, price: 134 },
        { name: "Big Mac", quantity: 1, price: 200 },
      ],
      deliveryFee: 50,
      isAccepted: false,
    };
    setOrderState(initialOrder);
  }, [dispatch]);

  const subtotal = order ? order.products.reduce((sum, product) => sum + product.quantity * product.price, 0) : 0;
  const total = subtotal + (order ? order.deliveryFee : 0);

  // Verificar el estado inicial en Redux antes de Payout
  console.log("Estado inicial en Redux (debería estar vacío):", orderFromState);

  return (
    <div className="max-w-full bg-[#FFFAF2]">
      <Header />
      <main className="p-[30px]">
        <section className="mb-6 flex-col flex gap-3">
          <p className="text-[18px] text-center font-bold text-[#0F383C] mb-3">Checkout and Pay</p>
          <div className="w-full bg-[#FFFFFF] rounded-lg p-4 flex flex-col items-center justify-center">
            {isLoaded ? (
              <GoogleMap mapContainerStyle={mapContainerStyle} center={center} zoom={15}>
                <Marker position={center} />
              </GoogleMap>
            ) : (
              <div>Loading Map...</div>
            )}
            <div className="flex items-center mt-4">
              <MapPinIcon className="w-6 h-6 text-gray-600" />
              <p className="ml-2 text-gray-600">{order?.address}</p>
            </div>
          </div>
        </section>

        <section className="mb-6">
          <h2 className="text-lg font-bold mb-3">Order Summary</h2>
          {order ? (
            <div>
              <div className="flex space-x-4">
                <div className="w-[50px] h-[50px] bg-[#D13A27] rounded-full p-4 flex items-center justify-center">
                  <img src={order.restaurantImage} alt={order.restaurant} className="" />
                </div>
                <div className="flex justify-center flex-col w-full">
                  <p className="font-bold">{order.restaurant}</p>
                  {order.products.map((product, index) => (
                    <div key={index} className="w-full flex items-center justify-between">
                      <div className="flex flex-row items-center gap-2">
                        <span className="w-[30px] h-[30px] bg-gray-200 rounded-md text-[14px] flex items-center justify-center">
                          {product.quantity}
                        </span>
                        <p>{product.name}</p>
                      </div>
                      <span className="font-bold">${product.price * product.quantity}.00</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <p>No order has been created yet.</p>
          )}
        </section>

        <section className="flex flex-col gap-[15px]">
          <div className="flex items-center text-gray-600 w-full justify-between">
            <p className="m-0">Subtotal</p>
            <span>${subtotal}.00</span>
          </div>
          <div className="flex items-center w-full text-gray-600 justify-between">
            <p className="m-0">Delivery Fee</p>
            <span>${order ? order.deliveryFee : 0}.00</span>
          </div>
          <div className="flex items-center w-full text-gray-600 justify-between">
            <p className="m-0">Total</p>
            <span>${total}.00</span>
          </div>
        </section>

        <section className="flex w-full mt-8 items-center justify-center">
          <Link href={"/confirmation"} className="flex w-full items-center justify-center">
            <button
              onClick={() => {
                makeOrder();
              }}
              className="max-w-[350px] w-full bg-[#D76C45] h-[57px] font-bold rounded-md text-[#FFFFFF]"
            >
              Payout
            </button>
          </Link>
        </section>
      </main>
    </div>
  );
};

export default Checkout;
