import React, { useState } from "react";
import {
  ChevronRightIcon,
  CoffeeIcon,
  GridIcon,
  HeartIcon,
  MenuIcon,
  ShoppingBagIcon,
  ShoppingCartIcon,
  MapPinIcon
} from "lucide-react";
import { GoogleMap, LoadScript, Marker } from "@react-google-maps/api";


interface Product {
  name: string;
  quantity: number;
  price: number;
}

interface Order {
  restaurant: string;
  products: Product[];
  deliveryFee: number;
}

const DispatcherOrder: React.FC = () => {

  const mapContainerStyle = {
    width: "100%",
    height: "300px",
  };

  const center = {
    lat: -3.745, // Coordenadas de ejemplo
    lng: -38.523, // Coordenadas de ejemplo
  };

  const address = "123 Main St, Springfield, USA";

  const order: Order = {
    restaurant: "McDonald's",
    products: [
      { name: "Cheese Fries", quantity: 2, price: 134 },
      { name: "Big Mac", quantity: 1, price: 200 },
    ],
    deliveryFee: 50,
  };

  const subtotal = order.products.reduce((sum, product) => sum + product.quantity * product.price, 0);
  const total = subtotal + order.deliveryFee;

  return (
    <div className="max-w-full bg-white">
      <main className="p-[30px]">
        <section className="mb-6 flex-col flex gap-3">
          <p className="text-[18px] text-center font-bold text-gray-600 mb-3">Checkout and Pay</p>
          <div className="w-full bg-[#E8F5E9] rounded-lg p-4 flex flex-col items-center justify-center">
            <LoadScript googleMapsApiKey="TU_CLAVE_DE_API_DE_GOOGLE_MAPS">
              <GoogleMap mapContainerStyle={mapContainerStyle} center={center} zoom={15}>
                <Marker position={center} />
              </GoogleMap>
            </LoadScript>
            <div className="flex items-center mt-4">
              <MapPinIcon className="w-6 h-6 text-gray-600" />
              <p className="ml-2 text-gray-600">{address}</p>
            </div>
          </div>
        </section>

        <section className="mb-6">
          <h2 className="text-lg font-bold mb-3">Order Summary</h2>
          <div>
            <div className="flex space-x-4">
              <div className="w-[50px] h-[50px] bg-[#D13A27] rounded-full p-4 flex items-center justify-center">
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/McDonald%27s_Golden_Arches.svg/1200px-McDonald%27s_Golden_Arches.svg.png"
                  alt={order.restaurant}
                  className=""
                />
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
        </section>

        <section className="flex flex-col">
          <div className="flex items-center text-gray-600  w-full justify-between">
            <p className="text-gray-600 ">Subtotal</p>
            <span>${subtotal}.00</span>
          </div>
          <div className="flex items-center w-full text-gray-600  justify-between">
            <p>Delivery Fee</p>
            <span>${order.deliveryFee}.00</span>
          </div>
          <div className="flex items-center w-full text-gray-600  justify-between">
            <p>Total</p>
            <span>${total}.00</span>
          </div>
        </section>

        <section className="flex w-full items-center justify-center">
          <button className="max-w-[300px] w-full bg-[#E8F5E9] h-[50px] font-bold rounded-md">Payout</button>
        </section>
      </main>
    </div>
  );
};

export default DispatcherOrder;
