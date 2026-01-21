# frozen_string_literal: true

require "prawn"
require "prawn/table"

class TicketPdfService
  def initialize(reservation)
    @reservation = reservation
    @trip = reservation.trip
    @route = @trip.route
  end

  def generate
    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      header(pdf)
      trip_info(pdf)
      passengers_table(pdf)
      payment_info(pdf)
      footer(pdf)
    end.render
  end

  private

  def header(pdf)
    pdf.text "POSKU", size: 28, style: :bold, color: "4F46E5"
    pdf.text "Comprobante de Pasaje", size: 14, color: "666666"
    pdf.move_down 10

    # Locator code box
    pdf.bounding_box([pdf.bounds.right - 150, pdf.cursor + 50], width: 150, height: 50) do
      pdf.stroke_bounds
      pdf.move_down 10
      pdf.text "Código de Reserva", size: 8, align: :center, color: "666666"
      pdf.text @reservation.locator_code, size: 20, style: :bold, align: :center
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20
  end

  def trip_info(pdf)
    pdf.text "Información del Viaje", size: 14, style: :bold
    pdf.move_down 10

    trip_data = [
      ["Origen:", @route.origin_terminal.display_name],
      ["Destino:", @route.destination_terminal.display_name],
      ["Fecha:", @trip.departure_at.strftime("%A %d de %B, %Y").capitalize],
      ["Hora de salida:", @trip.departure_at.strftime("%H:%M")],
      ["Hora de llegada:", @trip.arrival_at.strftime("%H:%M")],
      ["Duración:", @route.duration_formatted],
      ["Tipo de bus:", @trip.bus.bus_type_label]
    ]

    pdf.table(trip_data, width: pdf.bounds.width, cell_style: { borders: [], padding: [4, 8] }) do |table|
      table.column(0).font_style = :bold
      table.column(0).width = 120
    end

    pdf.move_down 20
  end

  def passengers_table(pdf)
    pdf.text "Pasajeros", size: 14, style: :bold
    pdf.move_down 10

    header_row = ["Nombre", "Documento", "Asiento"]
    passenger_rows = @reservation.passengers.map do |p|
      [p.full_name, "#{p.document_type_label}: #{p.document_number}", p.seat_number]
    end

    pdf.table([header_row] + passenger_rows, width: pdf.bounds.width, header: true) do |table|
      table.row(0).font_style = :bold
      table.row(0).background_color = "E5E7EB"
      table.cells.padding = [8, 10]
      table.cells.borders = [:bottom]
      table.cells.border_width = 0.5
      table.cells.border_color = "D1D5DB"
    end

    pdf.move_down 20
  end

  def payment_info(pdf)
    pdf.text "Información de Pago", size: 14, style: :bold
    pdf.move_down 10

    seats_data = @reservation.reservation_seats.map do |seat|
      ["Asiento #{seat.seat_number}", Seat::SEAT_CLASSES[seat.seat_class] || seat.seat_class, seat.formatted_price]
    end

    if seats_data.any?
      pdf.table(seats_data, width: pdf.bounds.width) do |table|
        table.cells.padding = [6, 10]
        table.cells.borders = []
        table.column(2).align = :right
      end
    end

    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text "Total: #{@reservation.formatted_total}", size: 16, style: :bold, align: :right

    pdf.move_down 10

    # Payment status
    status_color = @reservation.status == "confirmed" ? "059669" : "D97706"
    pdf.text "Estado: #{@reservation.status_label}", size: 12, color: status_color
  end

  def footer(pdf)
    pdf.move_down 30
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text "Condiciones de Viaje", size: 10, style: :bold
    pdf.move_down 5

    conditions = [
      "• Presente este comprobante al momento de abordar junto con su documento de identidad.",
      "• Llegue al terminal al menos 30 minutos antes de la hora de salida.",
      "• El equipaje permitido es de 2 maletas de hasta 23kg cada una.",
      "• No se permiten cambios ni devoluciones una vez confirmada la compra."
    ]

    conditions.each do |condition|
      pdf.text condition, size: 8, color: "666666"
    end

    pdf.move_down 15
    pdf.text "Contacto: soporte@posku.cl | www.posku.cl", size: 8, color: "999999", align: :center

    # Generated timestamp
    pdf.move_down 5
    pdf.text "Generado el #{Time.current.strftime('%d/%m/%Y %H:%M')}", size: 8, color: "CCCCCC", align: :center
  end
end
