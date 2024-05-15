import { LightningElement, api } from "lwc";

const DAY_TYPE = {
  daysOfMonth: "daysOfMonth",
  daysOfWeek: "daysOfWeek"
};

export default class CronBuilder extends LightningElement {
  selectedTemplate = "";

  enabledSelectors = [];
  errors = [];

  _templates;
  @api
  set templates(val) {
    this._templates = val;
    this.selectedTemplate = val[0].value;
  }
  get templates() {
    return this._templates;
  }

  dayTypes = [
    { label: "Days of the Month", value: DAY_TYPE.daysOfMonth },
    { label: "Days of the Week", value: DAY_TYPE.daysOfWeek }
  ];

  dayType = DAY_TYPE.daysOfMonth;

  columns = [
    {
      label: "All",
      fieldName: "label",
      wrapText: true,
      hideDefaultActions: true
    }
  ];

  months = [
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
  allMonths = this.months.map((v) => v.value);

  dayCols = [
    {
      label: "Day",
      fieldName: "label"
    }
  ];

  // intentionally limited to 28
  // >28 might not run every month (like Feb)
  // need more control? use advanced mode
  days = [
    { label: "1", value: "1" },
    { label: "2", value: "2" },
    { label: "3", value: "3" },
    { label: "4", value: "4" },
    { label: "5", value: "5" },
    { label: "6", value: "6" },
    { label: "7", value: "7" },
    { label: "8", value: "8" },
    { label: "9", value: "9" },
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
  allDays = this.days.map((v) => v.value);

  weekdays = [
    { label: "Sunday", value: "SUN" },
    { label: "Monday", value: "MON" },
    { label: "Tuesday", value: "TUE" },
    { label: "Wednesday", value: "WED" },
    { label: "Thursday", value: "THU" },
    { label: "Friday", value: "FRI" },
    { label: "Saturday", value: "SAT" }
  ];
  allWeekdays = this.weekdays.map((v) => v.value);

  hourCols = [
    {
      label: "Hour",
      fieldName: "label"
    }
  ];

  hours = [
    { label: "12 Midnight", value: "0" },
    { label: "1 AM", value: "1" },
    { label: "2 AM", value: "2" },
    { label: "3 AM", value: "3" },
    { label: "4 AM", value: "4" },
    { label: "5 AM", value: "5" },
    { label: "6 AM", value: "6" },
    { label: "7 AM", value: "7" },
    { label: "8 AM", value: "8" },
    { label: "9 AM", value: "9" },
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
  allHours = this.hours.map((v) => v.value);

  minuteCols = [
    {
      label: "Minute",
      fieldName: "label"
    }
  ];
  // trying to keep it simple, only 5-min granularity
  // possibly make it configurable later
  minutes = [
    { label: "00", value: "0" },
    { label: "05", value: "5" },
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
  allMinutes = this.minutes.map((v) => v.value);

  selectedMonths = [...this.allMonths];

  selectedDays = [...this.allDays];

  selectedWeekdays = ["?"];

  selectedHours = [...this.allHours];
  selectedMinutes = ["0"];

  /**
   * GETTERS
   */
  get chooseIndividualMonths() {
    return !this.isEveryMonth;
  }

  get shouldDisplaySingleHourSelector() {
    return this.enabledSelectors.includes("single-hour");
  }

  get shouldDisplaySingleMinuteSelector() {
    return this.enabledSelectors.includes("single-minute");
  }

  // get the first selected hour of the day for single-select combo boxes
  get selectedHourOfDay() {
    return this.selectedHours[0];
  }

  get selectedMinuteOfTheHour() {
    return this.selectedMinutes[0];
  }

  get isWeekDayType() {
    return this.dayType === DAY_TYPE.daysOfWeek;
  }

  /**
   * HANDLERS
   */

  handleTemplateChange(event) {
    this.selectedTemplate = event.detail.value;
    this.processTemplate();
  }

  handeTabActivate(event) {
    if (event.target.value === "templates") {
      this.processTemplate();
      return;
    }
    this.selectedMonths = [...this.allMonths];
    this.selectedDays = [...this.allDays];
    this.selectedHours = [...this.allHours];
    this.selectedWeekdays = ["?"];
    if (event.target.value === "daily") {
      // default to early hours of the morning for once-daily template
      this.selectedHours = ["3"];
    }
    this.publishCronString();
  }

  handleMonthChange(event) {
    this.selectedMonths = event.detail.selectedRows.map((r) => r.value);
    this.publishCronString();
  }

  handleDayTypeChange(event) {
    this.dayType = event.detail.value;
    if (this.dayType === DAY_TYPE.daysOfWeek) {
      this.selectedWeekdays = [...this.allWeekdays];
      this.selectedDays = ["?"];
    } else {
      this.selectedWeekdays = ["?"];
      this.selectedDays = [...this.allDays];
    }
    this.publishCronString();
  }

  handleDayChange(event) {
    this.selectedDays = event.detail.selectedRows.map((r) => r.value);
    this.publishCronString();
  }

  handleWeekdayChange(event) {
    this.selectedWeekdays = event.detail.selectedRows.map((r) => r.value);
    this.publishCronString();
  }

  handleHourChange(event) {
    this.selectedHours = event.detail.selectedRows.map((r) => r.value);
    this.publishCronString();
  }

  handleSingleHourChange(event) {
    this.selectedHours = [event.detail.value];
    this.publishCronString();
  }

  handleMinuteChange(event) {
    this.selectedMinutes = event.detail.selectedRows.map((r) => r.value);
    this.publishCronString();
  }

  handleSingleMinuteChange(event) {
    this.selectedMinutes = [event.detail.value];
    this.publishCronString();
  }

  /**
   * LOGIC
   */

  processTemplate() {
    const selectedTemplate = this.templates.find(
      (t) => t.value === this.selectedTemplate
    );
    // can enable/disable various selected
    this.enabledSelectors = selectedTemplate.selectors ?? [];
    // take presets from the provided template
    this.selectedMinutes = selectedTemplate?.presets?.minutes ?? ["0"];
    this.selectedHours = selectedTemplate?.presets?.hours ?? this.allHours;
    this.selectedDays = selectedTemplate?.presets?.days ?? this.allDays;
    this.selectedWeekdays = selectedTemplate?.presets?.weekdays ?? ["?"];
    this.selectedMonths = selectedTemplate?.presets?.months ?? this.allMonths;
    this.publishCronString();
  }

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
    this.errors = [];
    // for minute input, each variation requires a differen Cron String
    // all others can have multiple values
    if (this.selectedMonths.length === 0) {
      this.errors.push("Must select at least one month");
    }
    const months =
      this.selectedMonths.length === this.allMonths.length
        ? "*"
        : this.selectedMonths.join(",");

    if (this.selectedDays.length === 0) {
      this.errors.push("Must select at least one day");
    }
    const daysOfMonth =
      this.selectedDays.length === this.allDays.length
        ? "*"
        : this.selectedDays.join(",");

    if (this.selectedWeekdays.length === 0) {
      this.errors.push("Must select at least one weekday");
    }
    const daysOfWeek =
      this.selectedWeekdays.length === this.allWeekdays.length
        ? "*"
        : this.selectedWeekdays.join(",");

    if (this.selectedHours.length === 0) {
      this.errors.push("Must select at least one hour");
    }
    const hours =
      this.selectedHours.length === this.allHours.length
        ? "*"
        : this.selectedHours.join(",");
    const seconds = "0";
    const crons = [];

    if (this.selectedMinutes.length === 0) {
      this.errors.push("Must select at least one minute");
    }
    if (this.errors.length > 0) {
      return crons;
    }
    // for every minute
    for (let min of this.selectedMinutes) {
      crons.push(
        `${seconds} ${min} ${hours} ${daysOfMonth} ${months} ${daysOfWeek}`
      );
    }
    console.log("Calculated Cron strings", JSON.stringify(crons));
    return crons;
  }
}
