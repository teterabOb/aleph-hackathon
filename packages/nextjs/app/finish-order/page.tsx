"use client";

import React from "react";
import { RootState } from "../../store/store";
import { MapPinIcon } from "lucide-react";
import type { NextPage } from "next";
import { useSelector } from "react-redux";

const Confirmation: NextPage = () => {
  return (
    <div className="w-full bg-[#FFFAF2] p-8 min-h-screen justify-center items-center flex flex-col">
      <h1 className="text-2xl font-bold text-gray-700 text-center mb-6">Finalizar Compra</h1>
    </div>
  );
};

export default Confirmation;
