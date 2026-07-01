# Optional controller snippets for better htmx behavior.
# This file is not used by Rails generators automatically.
#
# Paste/adapt these into generated scaffold controllers if desired.
#
# Create:
#
# if @record.save
#   if request.headers["HX-Request"]
#     render partial: "record", locals: { record: @record }, status: :created
#   else
#     redirect_to @record, notice: "Record was successfully created."
#   end
# else
#   render :new, status: :unprocessable_entity
# end
#
# Update:
#
# if @record.update(record_params)
#   if request.headers["HX-Request"]
#     render partial: "record", locals: { record: @record }
#   else
#     redirect_to @record, notice: "Record was successfully updated."
#   end
# else
#   render :edit, status: :unprocessable_entity
# end
#
# Destroy:
#
# @record.destroy!
#
# if request.headers["HX-Request"]
#   head :ok
# else
#   redirect_to records_path, notice: "Record was successfully destroyed."
# end
