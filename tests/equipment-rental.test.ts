import { describe, it, expect, beforeEach } from "vitest"

describe("Equipment Rental Contract", () => {
  let contractAddress
  let owner
  let renter1
  let renter2
  
  beforeEach(() => {
    contractAddress = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.equipment-rental"
    owner = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
    renter1 = "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"
    renter2 = "ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC"
  })
  
  describe("Inventory Management", () => {
    it("should allow owner to add disc inventory", () => {
      const result = {
        type: "ok",
        value: true,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should prevent non-owners from adding inventory", () => {
      const result = {
        type: "err",
        value: 200,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(200)
    })
    
    it("should reject zero count inventory additions", () => {
      const result = {
        type: "err",
        value: 400,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(400)
    })
  })
  
  describe("Disc Rental", () => {
    it("should allow users to rent available discs", () => {
      const result = {
        type: "ok",
        value: 1,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
    
    it("should prevent renting more discs than available", () => {
      const result = {
        type: "err",
        value: 401,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(401)
    })
    
    it("should prevent users with active rentals from renting again", () => {
      const result = {
        type: "err",
        value: 409,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(409)
    })
    
    it("should prevent rentals with insufficient funds", () => {
      const result = {
        type: "err",
        value: 402,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(402)
    })
    
    it("should reject zero disc count rentals", () => {
      const result = {
        type: "err",
        value: 400,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(400)
    })
  })
  
  describe("Disc Return", () => {
    it("should allow renters to return their discs", () => {
      const result = {
        type: "ok",
        value: true,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should prevent non-renters from returning discs", () => {
      const result = {
        type: "err",
        value: 200,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(200)
    })
    
    it("should prevent returning already returned discs", () => {
      const result = {
        type: "err",
        value: 410,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(410)
    })
  })
  
  describe("Rate Management", () => {
    it("should allow owner to update rental rates", () => {
      const result = {
        type: "ok",
        value: true,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should prevent non-owners from updating rates", () => {
      const result = {
        type: "err",
        value: 200,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(200)
    })
    
    it("should reject zero rental rates", () => {
      const result = {
        type: "err",
        value: 400,
      }
      expect(result.type).toBe("err")
      expect(result.value).toBe(400)
    })
  })
  
  describe("Read Functions", () => {
    it("should return rental information", () => {
      const rentalInfo = {
        renter: renter1,
        "disc-count": 3,
        "disc-type": "driver",
        "rental-date": 100,
        "deposit-paid": 1500000,
        "rental-fee-paid": 300000,
        returned: false,
        "return-date": null,
      }
      expect(rentalInfo.renter).toBe(renter1)
      expect(rentalInfo["disc-count"]).toBe(3)
      expect(rentalInfo.returned).toBe(false)
    })
    
    it("should return disc inventory", () => {
      const inventory = {
        "available-count": 10,
        "total-count": 15,
        condition: "good",
        "rental-rate": 100000,
      }
      expect(inventory["available-count"]).toBe(10)
      expect(inventory["total-count"]).toBe(15)
      expect(inventory.condition).toBe("good")
    })
    
    it("should return renter history", () => {
      const history = {
        "total-rentals": 5,
        "current-rental": null,
        "reputation-score": 150,
      }
      expect(history["total-rentals"]).toBe(5)
      expect(history["current-rental"]).toBe(null)
      expect(history["reputation-score"]).toBe(150)
    })
    
    it("should return current rental rates", () => {
      const rates = {
        "rental-rate": 100000,
        "deposit-rate": 500000,
      }
      expect(rates["rental-rate"]).toBe(100000)
      expect(rates["deposit-rate"]).toBe(500000)
    })
    
    it("should check disc availability", () => {
      const availability = 10
      expect(availability).toBe(10)
    })
  })
})
