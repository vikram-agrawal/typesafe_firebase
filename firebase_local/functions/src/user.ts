import { Request, Response, Router } from "express";
import { logger } from "firebase-functions";

const parseData = (req: Request): any => {
  if (typeof req.body?.data === "string") {
    try {
      return JSON.parse(req.body.data);
    } catch (e) {
      logger.error("Failed to parse JSON string from req.body.data", e);
      throw new Error("Invalid JSON string in data field");
    }
  }
  return req.body?.data;
};

export const userRouter = Router()

userRouter.post("/load", (req: Request, res: Response) => {
  logger.info("/load called.");
  const data = parseData(req);
  logger.info(`Value: ${data.Value}`);
  res.status(200).json({
    success: true,
    data: {
      uid: data.Value,
      name: `User_${data.Value}`
    }
  });
});
