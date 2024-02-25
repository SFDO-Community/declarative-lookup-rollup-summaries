import { LightningElement } from "lwc";

export default class CronBuilder extends LightningElement {
  isWeekDayType = true;

  monthOptions = [
    { label: "Every*", value: "*" },
    { label: "January", value: "JAN" },
    { label: "February", value: "FEB" },
    { label: "March", value: "MAR" },
    { label: "April", value: "APR" },
    { label: "May", value: "MAY" },
    { label: "June", value: "JUN" },
    { label: "July", value: "JUL" },
    { label: "August", value: "AUG" },
    { label: "September", value: "SEP" },
    { label: "October", value: "OCT" },
    { label: "November", value: "NOV" },
    { label: "December", value: "DEC" }
  ];

  // intentionally limited to 28
  // >28 might not run every month (like Feb)
  // need more control? use advanced mode
  daysOfMonthOptions = [
    { label: "Every*", value: "*" },
    { label: "1", value: "01" },
    { label: "2", value: "02" },
    { label: "3", value: "03" },
    { label: "4", value: "04" },
    { label: "5", value: "05" },
    { label: "6", value: "06" },
    { label: "7", value: "07" },
    { label: "8", value: "08" },
    { label: "9", value: "09" },
    { label: "10", value: "10" },
    { label: "11", value: "11" },
    { label: "12", value: "12" },
    { label: "13", value: "13" },
    { label: "14", value: "14" },
    { label: "15", value: "15" },
    { label: "16", value: "16" },
    { label: "17", value: "17" },
    { label: "18", value: "18" },
    { label: "19", value: "19" },
    { label: "20", value: "20" },
    { label: "21", value: "21" },
    { label: "22", value: "22" },
    { label: "23", value: "23" },
    { label: "24", value: "24" },
    { label: "25", value: "25" },
    { label: "26", value: "26" },
    { label: "27", value: "27" },
    { label: "28", value: "28" },
    { label: "Last day of month", value: "L" }
  ];

  daysOfWeekOptions = [
    { label: "Every*", value: "*" },
    { label: "Sunday", value: "SUN" },
    { label: "Monday", value: "MON" },
    { label: "Tuesday", value: "TUE" },
    { label: "Wednesday", value: "WED" },
    { label: "Thursday", value: "THU" },
    { label: "Friday", value: "FRI" },
    { label: "Saturday", value: "SAT" }
  ];

  hoursOfDayOptions = [
    { label: "Every*", value: "*" },
    { label: "Midnight", value: "00" },
    { label: "1 AM", value: "01" },
    { label: "2 AM", value: "02" },
    { label: "3 AM", value: "03" },
    { label: "4 AM", value: "04" },
    { label: "5 AM", value: "05" },
    { label: "6 AM", value: "06" },
    { label: "7 AM", value: "07" },
    { label: "8 AM", value: "08" },
    { label: "9 AM", value: "09" },
    { label: "10 AM", value: "10" },
    { label: "11 AM", value: "11" },
    { label: "12 Noon", value: "12" },
    { label: "1 PM", value: "13" },
    { label: "2 PM", value: "14" },
    { label: "3 PM", value: "15" },
    { label: "4 PM", value: "16" },
    { label: "5 PM", value: "17" },
    { label: "6 PM", value: "18" },
    { label: "7 PM", value: "19" },
    { label: "8 PM", value: "20" },
    { label: "9 PM", value: "21" },
    { label: "10 PM", value: "22" },
    { label: "11 PM", value: "23" }
  ];

  // trying to keep it simple, only 5-min granularity
  // possibly make it configurable later
  minutesOfHourOptions = [
    { label: "00", value: "00" },
    { label: "05", value: "05" },
    { label: "10", value: "10" },
    { label: "15", value: "15" },
    { label: "20", value: "20" },
    { label: "25", value: "25" },
    { label: "30", value: "30" },
    { label: "35", value: "35" },
    { label: "40", value: "40" },
    { label: "45", value: "45" },
    { label: "50", value: "50" },
    { label: "55", value: "55" }
  ];

  selectedMonths = ["*"];

  selectedDaysOfMonth = ["*"];

  selectedDaysOfWeek = ["?"];

  selectedHoursOfDay = ["*"];
  selectedMinutesOfDay = ["00"];

  connectedCallback() {
    this.publishCronString();
  }
  /**
   * GETTERS
   */
  get chooseIndividualMonths() {
    return !this.isEveryMonth;
  }

  get chooseIndividualDaysOfMonth() {
    return this.daysType === "daysofmonth";
  }

  get chooseIndividualDaysOfWeek() {
    return this.daysType === "daysofweek";
  }

  /**
   * HANDLERS
   */

  handeTabActivate(event) {
    this.selectedMonths =
      this.selectedDaysOfMonth =
      this.selectedHoursOfDay =
        ["*"];
    this.selectedDaysOfWeek = ["?"];
    if (event.target.value === "daily") {
      // default to early hours of the morning for once-daily template
      this.selectedHoursOfDay = ["03"];
    }
    this.publishCronString();
  }

  handleSelectedMonthChange(event) {
    this.selectedMonths = this.processDualBoxEvery(
      this.selectedMonths,
      event.detail.value
    );
    this.publishCronString();
  }

  handleDaysTypeChange(event) {
    this.isWeekDayType = event.detail.checked;
    if (this.isWeekDayType) {
      this.selectedDaysOfWeek = ["*"];
      this.selectedDaysOfMonth = ["?"];
    } else {
      this.selectedDaysOfWeek = ["?"];
      this.selectedDaysOfMonth = ["*"];
    }
    this.publishCronString();
  }

  handleSelectedDaysOfMonthChange(event) {
    this.selectedDaysOfMonth = this.processDualBoxEvery(
      this.selectedDaysOfMonth,
      event.detail.value
    );
    this.publishCronString();
  }

  handleSelectedDaysOfWeekChange(event) {
    this.selectedDaysOfWeek = this.processDualBoxEvery(
      this.selectedDaysOfWeek,
      event.detail.value
    );
    this.publishCronString();
  }

  handleSelectedHoursOfDayChange(event) {
    this.selectedHoursOfDay = this.processDualBoxEvery(
      this.selectedHoursOfDay,
      event.detail.value
    );
    this.publishCronString();
  }

  handleSelectedMinutesOfDayChange(event) {
    this.selectedMinutesOfDay = event.detail.value;
    this.publishCronString();
  }

  /**
   * LOGIC
   */

  publishCronString() {
    // emit custom event
    this.dispatchEvent(
      new CustomEvent("cronupdate", {
        detail: {
          value: this.buildCronStrings()
        }
      })
    );
  }

  buildCronStrings() {
    // TODO: handle advanced mode

    // for minute input, each variation requires a differen Cron String
    // all others can be common
    // build strings for each section except min & hour
    const seconds = "0";
    const daysOfMonth = this.selectedDaysOfMonth.join(",");
    const months = this.selectedMonths.join(",");
    const daysOfWeek = this.selectedDaysOfWeek.join(",");
    const hours = this.selectedHoursOfDay.join(",");
    // TODO: error guards
    const crons = [];
    // for every minute
    for (let min of this.selectedMinutesOfDay) {
      crons.push(
        `${seconds} ${min} ${hours} ${daysOfMonth} ${months} ${daysOfWeek}`
      );
    }
    console.log("Calculated Cron strings", JSON.stringify(crons));
    return crons;
  }

  processDualBoxEvery(oldValues, newValues) {
    newValues.sort();
    // used to have Every by itself, now added something
    if (oldValues.includes("*") && newValues.length > 1) {
      // filter out "Every"
      return newValues.filter((v) => v !== "*");
    }
    // Every is new, remove everything else
    if (newValues.includes("*")) {
      return ["*"];
    }
    if (newValues.length === 0) {
      return ["*"];
    }
    return newValues;
  }
}
