import { normalizeDate } from '../models/transaction'

interface DatePickerOptions {
  defaultValue?: Date
  maxDate?: Date
  minDate?: Date
  onPick: (date: Date) => void
}

export function useDatePicker() {
  function pickDate(options: DatePickerOptions) {
    const input = document.createElement('input')
    input.type = 'date'
    if (options.defaultValue) input.value = normalizeDate(options.defaultValue)
    if (options.maxDate) input.max = normalizeDate(options.maxDate)
    if (options.minDate) input.min = normalizeDate(options.minDate)
    input.onchange = () => {
      if (input.value) options.onPick(new Date(input.value + 'T00:00:00'))
    }
    input.click()
  }

  return { pickDate }
}
