const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
  // Show all appointments
  const appointments = await prisma.appointments.findMany()
  console.log('All Appointments:')
  console.log(appointments)

  // Show all patients
  const patients = await prisma.patients.findMany()
  console.log('\nAll Patients:')
  console.log(patients)

  // Show all doctors
  const doctors = await prisma.doctors.findMany()
  console.log('\nAll Doctors:')
  console.log(doctors)
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())