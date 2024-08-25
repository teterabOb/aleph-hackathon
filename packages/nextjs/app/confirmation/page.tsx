"use client";
import React from "react";
import { RootState } from "../../store/store";
import { MapPinIcon } from "lucide-react";
import type { NextPage } from "next";
import { useSelector } from "react-redux";

const Confirmation: NextPage = () => {
  const order = useSelector((state: RootState) => state.order.order);

  if (!order) {
    return (
      <div className="max-w-full bg-white p-8 text-center">
        <h1 className="text-2xl font-bold text-gray-700">No Order Found</h1>
        <p className="text-gray-600">Please go back and complete your order.</p>
      </div>
    );
  }

  const subtotal = order.products.reduce((sum, product) => sum + product.quantity * product.price, 0);
  const total = subtotal + order.deliveryFee;

  return (
    <div className="w-full bg-[#FFFAF2] p-8 min-h-screen justify-center items-center flex flex-col">
      <h1 className="text-2xl font-bold text-gray-700 text-center mb-6">Order Confirmation</h1>

      <div className="flex w-full flex-col items-center bg-[#FFFFFF] p-4 rounded-lg shadow-md">
        <div className=" flex flex-col items-center">
          <div className="bg-gray-200 w-[150px] h-[150px] p-6 rounded-full mb-4 shadow-inner">
            <img src={order.restaurantImage} alt={order.restaurant} className="object-contain" />
          </div>
          <h2 className="text-lg font-bold">{order.restaurant}</h2>
          <div className="flex items-center mt-2">
            <MapPinIcon className="w-6 h-6 text-gray-600" />
            <p className="ml-2 text-gray-600">{order.address}</p>
          </div>
        </div>

        <div className="w-full mt-6">
          <h3 className="text-lg font-bold mb-3">Order Summary</h3>
          <div className="space-y-2">
            {order.products.map((product, index) => (
              <div key={index} className="flex justify-between">
                <div className="text-gray-700">
                  {product.quantity} x {product.name}
                </div>
                <div className="font-bold text-gray-900">${product.price * product.quantity}.00</div>
              </div>
            ))}
          </div>
        </div>

        <div className="w-full mt-4">
          <div className="flex justify-between text-gray-700">
            <span>Subtotal</span>
            <span>${subtotal}.00</span>
          </div>
          <div className="flex justify-between text-gray-700">
            <span>Delivery Fee</span>
            <span>${order.deliveryFee}.00</span>
          </div>
          <div className="flex justify-between font-bold text-gray-900 mt-2">
            <span>Total</span>
            <span>${total}.00</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Confirmation;
