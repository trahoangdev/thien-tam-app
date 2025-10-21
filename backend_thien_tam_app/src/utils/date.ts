import { fromZonedTime, toZonedTime } from "date-fns-tz";
const ZONE = "Asia/Ho_Chi_Minh";

export const startOfLocalDay = (d = new Date()) =>
  fromZonedTime(new Date(toZonedTime(d, ZONE).toDateString()), ZONE);

export const rangeOfMonthLocal = (year: number, month1to12: number) => {
  const z = ZONE;
  const localStart = new Date(year, month1to12 - 1, 1);
  const localEnd = new Date(year, month1to12, 1);
  return {
    from: fromZonedTime(localStart, z),
    to: fromZonedTime(localEnd, z),
  };
};

